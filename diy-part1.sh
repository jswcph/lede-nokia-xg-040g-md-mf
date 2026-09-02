#!/bin/bash
#================================================================
# diy-part1.sh
#================================================================

# 添加 Passwall 软件源
sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '1i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default

echo "diy-part1.sh executed successfully."
