#!/bin/bash
#================================================================
# diy-part2.sh
#================================================================

# 1. 向 an7581.mk 注入 md-ubi 机型定义
MAKEFILE_PATH="target/linux/airoha/image/an7581.mk"

if [ -f "$MAKEFILE_PATH" ]; then
    echo "Injecting nokia_xg-040g-md-ubi definition into $MAKEFILE_PATH ..."
    
    cat >> "$MAKEFILE_PATH" << 'EOF'

define Device/nokia_xg-040g-md-ubi
  $(call Device/nokia_xg-040g-md-common)
  DEVICE_DTS := an7581-nokia_xg-040g-md
  DEVICE_DTS_CONFIG := config@1
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBINIZE_OPTS := -E 5
  IMAGES += sysupgrade.itb recovery.itb
  IMAGE/sysupgrade.itb := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += nokia_xg-040g-md-ubi
EOF
    echo "Successfully injected md-ubi definition."
else
    echo "ERROR: $MAKEFILE_PATH not found!"
    exit 1
fi

# 2. 提前拉取并集成 Lucky 到 package 目录
if [ ! -d "package/lucky" ]; then
    echo "Cloning luci-app-lucky..."
    git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky
fi

# 3. 提前拉取并集成 OpenClash 到 package 目录
if [ ! -d "package/luci-app-openclash" ]; then
    echo "Cloning OpenClash..."
    git clone --depth=1 https://github.com/vernesong/OpenClash.git /tmp/OpenClash
    if [ -d "/tmp/OpenClash/luci-app-openclash" ]; then
        cp -rf /tmp/OpenClash/luci-app-openclash package/luci-app-openclash
    fi
    rm -rf /tmp/OpenClash
fi

# 4. 提前拉取并集成 Argon 主题
if [ ! -d "package/luci-theme-argon" ]; then
    echo "Cloning Argon theme..."
    git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
    git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
fi

# =====================================================
# 5. 写入自定义网络、IP、网口划分及默认密码配置
# =====================================================
mkdir -p files/etc/uci-defaults
mkdir -p files/etc

# ----------------- 1. 设置默认 root 密码为 password -----------------
echo "Setting default root password..."
SHADOW_FILE="files/etc/shadow"
DEFAULT_PASSWORD="password"
ROOT_HASH="$(openssl passwd -6 "${DEFAULT_PASSWORD}")"

if [ ! -f "${SHADOW_FILE}" ]; then
    cat > "${SHADOW_FILE}" <<EOF
root:${ROOT_HASH}:0:0:99999:7:::
EOF
else
    if grep -q '^root:' "${SHADOW_FILE}"; then
        sed -i -E "s#^root:[^:]*:#root:${ROOT_HASH}:#" "${SHADOW_FILE}"
    else
        echo "root:${ROOT_HASH}:0:0:99999:7:::" >> "${SHADOW_FILE}"
    fi
fi
chmod 600 "${SHADOW_FILE}"

# ----------------- 2. 写入 uci-defaults 默认网络与系统配置 -----------------
cat > files/etc/uci-defaults/99-custom-settings << 'EOF'
#!/bin/sh

# 修改 LAN 口 IP 为 192.168.6.1
uci set network.lan.ipaddr='192.168.6.1'
uci set network.lan.netmask='255.255.255.0'

# 配置 WAN 口：将 lan1 设置为 wan，协议为 dhcp
uci -q delete network.wan
uci set network.wan='interface'
uci set network.wan.device='lan1'
uci set network.wan.proto='dhcp'

# 配置 LAN 桥接：将 lan2, lan3, lan4 合并到 br-lan
uci -q delete network.br_lan
uci set network.br_lan='device'
uci set network.br_lan.name='br-lan'
uci set network.br_lan.type='bridge'

uci add_list network.br_lan.ports='lan2'
uci add_list network.br_lan.ports='lan3'
uci add_list network.br_lan.ports='lan4'

uci set network.lan.device='br-lan'

# 设置主机名
uci set system.@system[0].hostname='OpenWrt'

# 设置 Argon 主题和中文语言
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'

# 提交配置
uci commit system
uci commit network
uci commit luci

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-settings
echo "Custom settings and port mappings added successfully."
