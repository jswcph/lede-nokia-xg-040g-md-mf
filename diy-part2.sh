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
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate


# 如果 an7581.mk 中没有 nokia_xg-040g-md-ubi，则自动追加定义
cat >> target/linux/airoha/image/an7581.mk << 'EOF'

define Device/nokia_xg-040g-md-ubi
  $(call Device/FitImageLzma)
  $(call Device/nokia_xg-040g-md-common)
  DEVICE_VENDOR := Nokia
  DEVICE_MODEL := XG-040G-MD (UBI)
  DEVICE_DTS := an7581-nokia_xg-040g-md
  DEVICE_DTS_CONFIG := config@1
  IMAGE_SIZE := 131968k
  KERNEL_SIZE := 8192k
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/sysupgrade.itb := append-kernel | pad-to 8192k | append-ubi | pad-rootfs | append-metadata
endef
TARGET_DEVICES += nokia_xg-040g-md-ubi
EOF
