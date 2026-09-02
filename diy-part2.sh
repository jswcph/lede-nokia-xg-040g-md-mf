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
