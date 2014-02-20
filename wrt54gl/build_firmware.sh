#!/bin/sh
firmware_base_dir="firmware"
firmware_builder="${firmware_base_dir}/OpenWrt-ImageBuilder-brcm47xx-for-Linux-i686/"
firmware_image_folder="${firmware_builder}/bin/brcm47xx"
firmware_files="openwrt-brcm47xx-squashfs.trx openwrt-wrt54g-squashfs.bin"
package_list="base-files busybox crda dnsmasq dropbear firewall hotplug2 iptables iptables-mod-conntrack iptables-mod-nat iw kernel kmod-b43 kmod-b43legacy kmod-cfg80211 kmod-crc-ccitt kmod-crypto-aes kmod-crypto-arc4 kmod-crypto-core kmod-diag kmod-ipt-conntrack kmod-ipt-core kmod-ipt-nat kmod-ipt-nathelper kmod-mac80211 kmod-switch libc libgcc libip4tc libiwinfo libiwinfo-lua liblua libnl-tiny libuci libuci-lua libxtables lua luci luci-app-firewall luci-i18n-english luci-lib-core luci-lib-ipkg luci-lib-lmo luci-lib-nixio luci-lib-sys luci-lib-web luci-mod-admin-core luci-mod-admin-full luci-proto-core luci-sgi-cgi luci-theme-base luci-theme-openwrt mtd nvram opkg uci udevtrigger uhttpd wireless-tools wpad-mini openvpn kmod-tun libopenssl liblzo iptables-mod-ipopt ip iptables-mod-conntrack-extra -kmod-ppp -kmod-pppoe -luci-proto-ppp -ppp -ppp-mod-pppoe freepackets-wrt54gl"

./build_package.sh
if [ $? -ne 0 ] ; then
	exit 1
fi
cur=$(pwd)
cd ${firmware_builder}
make clean
make image PROFILE=Broadcom-b43 PACKAGES="${package_list}"
cd $cur

for f in $firmware_files ; do 
	cp ${firmware_image_folder}/$f ${firmware_base_dir}/
done
echo
echo "freepackets firmware files are located in ${firmware_base_dir}/"
echo
