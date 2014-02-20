#!/bin/bash
# build ipkg package
# install with:
# opkg install freepackets_wrt54gl.ipk --force-maintainer
# more infos on ipkg packages:
# http://buffalo.nas-central.org/wiki/Construct_ipkg_packages_%28for_developers%29
##################################################################################

source=add2distro
target=package
config_local="../config_local"
config="../config"
report_conf="vpn_report"

# options to be disabled in open vpn config file
openvpn_disable="explicit-exit-notify dhcp-renew dhcp-release"
sys_conf_vars="ap_ssid ap_pwd"

# if a local config exists - take it
if [ -d $config_local ] ; then
	echo "*** use local config files to build package ***"
	config=$config_local
fi
mandatory_files="${source}/CONTROL/control ${config}/password.txt ${config}/openvpn.ovpn"

# prepare ####################################################################
for f in $mandatory_files ; do
	if [ ! -f "${f}" ] ; then
		echo
		echo "missing file ${f}. abort."
		echo
		exit 1
	fi
done

# clean
rm -rf ${target}
mkdir ${target}

# data part ##################################################################
echo "create data.tar.gz"
cd ${source}
chmod a+x usr/sbin/*
chmod a+x etc/init.d/vpn
chmod a+x etc/firewall.user

# copy openvpn config and disable unsupported options
cp -f ../${config}/openvpn.ovpn etc/openvpn/openvpn.ovpn
for d in $openvpn_disable ; do
	if [ $(cat etc/openvpn/openvpn.ovpn | grep $d | wc -l) -ne 0 ] ; then
		echo "openvpn config - disable option: $d"
		sed -i "s/$d/#$d/g" etc/openvpn/openvpn.ovpn
	fi
done
# rewrite auth-user-pass to use /etc/openvpn/password.txt
sed -i "/auth-user-pass/c\auth-user-pass /etc/openvpn/password.txt" etc/openvpn/openvpn.ovpn
# set script-security  to 3
sed -i "/script-security/c\script-security 3" etc/openvpn/openvpn.ovpn

# copy password file
if [ $(cat ../${config}/password.txt | wc -l) -lt 2 ] ; then 
	echo
	echo "invalid config password file. must contain at least two lines."
	echo "first line is used as username, second one is treated as password"
	echo
	exit 1
fi
cp -f ../${config}/password.txt etc/openvpn/password.txt
chmod 600 etc/openvpn/password.txt

# apply config config
rm -f etc/config/$report_conf
if [ -f ../${config}/system.conf ] ; then
	for v in $sys_conf_vars ; do
		unset $v
	done
	. ../${config}/system.conf
	# ap ssid
	if [ ! -z "$ap_ssid" ] ; then
		sed -i "/ssid/c\ \toption 'ssid' '$ap_ssid'" etc/config/wireless
	fi
	# ap pwd
	if [ ! -z "$ap_pwd" ] ; then
		sed -i "/key/c\ \toption 'key' '$ap_pwd'" etc/config/wireless
	else
		sed -i "/key/c\#no password protection - enable password by setting option 'key' <password>" etc/config/wireless
	fi
	# stats reporting - config
	if [ ! -z "$stats_url" -a ! -z "$stats_interval" -a ! -z "$stats_key" ] ; then

		if [ $stats_interval -eq 0 ] ; then
			echo
			echo "stats_interval invalid. must be > 0."
			echo
			exit 1
		fi
		echo "stats_url=$stats_url" > etc/config/$report_conf
		echo "stats_interval=$stats_interval" >> etc/config/$report_conf
		echo "stats_key=$stats_key" >> etc/config/$report_conf
		chmod a+rx etc/config/$report_conf
	fi
fi

# create tar...
tar --exclude *~ -czf  data.tar.gz etc usr
cp data.tar.gz ../${target}/
cd ..
echo "DONE."

# control part ###############################################################
echo "create control.tar.gz"
cd ${source}
find etc/ -type f | grep -v "~" | sed 's/^/\//' > CONTROL/conffiles
cd CONTROL
#echo "#!/bin/sh" > postinst
#echo "\"" >> postinst
#echo "echo \"use me to do some nasty things after install\"" >> postinst
#echo "exit 0" >> postinst
#chmod a+x postinst
tar czf control.tar.gz control conffiles #postinst
cp control.tar.gz ../../${target}/
cd ../..
echo "DONE."

echo "create ipkg"
cd ${target}
echo 2.0 > debian-binary
tar czf freepackets_wrt54gl.ipk control.tar.gz data.tar.gz debian-binary
echo "DONE."

# create packages file
cat ../${source}/CONTROL/control > Packages
echo "MD5Sum: $(md5sum freepackets_wrt54gl.ipk | cut -d " " -f1)" >> Packages

rm -f control.tar.gz data.tar.gz debian-binary

echo
echo "package freepackets_wrt54.ipg build in ${target}"
echo "install with: opkg install freepackets_wrt54gl.ipk --force-maintainer"
echo 
