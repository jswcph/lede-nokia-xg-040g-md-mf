#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

#!/bin/bash
#================================================================
# diy-part2.sh
#================================================================

# 1. 检查 an7581.mk 文件是否存在
MAKEFILE_PATH="target/linux/airoha/image/an7581.mk"

if [ -f "$MAKEFILE_PATH" ]; then
    echo "Adding nokia_xg-040g-md-ubi definition to $MAKEFILE_PATH ..."
    
    # 使用追加符号将设备定义写入 Makefile 末尾
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

    echo "Successfully added nokia_xg-040g-md-ubi definition."
else
    echo "ERROR: $MAKEFILE_PATH not found!"
    exit 1
fi
