#!/bin/bash
# ssh-keygen -t dsa -f freepackets
# !!must be dsa!!

rtr_ip=192.168.1.101
rtr_usr=root

folder_prefix="add2distro/"
# list format: filename;permission
files=" /usr/sbin/vpn_shepherd;755 /usr/sbin/vpn_up;755 /usr/sbin/vpn_down;755 /etc/init.d/vpn;755 /etc/openvpn/cyberghost.ovpn;400 /etc/openvpn/pass.txt;400 /etc/config/firewall;644 /etc/firewall.user;755 /etc/resolv.conf;644 /etc/iproute2/rt_tables;644 /etc/config/wireless;644 /etc/config/network;644 /etc/config/dhcp;644 /etc/hotplug.d/button/buttons;755 /usr/sbin/public_net_direct;755 /usr/sbin/public_net_vpn;755 /usr/sbin/vpn_led;755"

# install developer key
if [ ! -f ~/.ssh/freepackets ] ; then
	echo "copy freepackets dev key to ~/.ssh"
	cp dev_key/freepackets ~/.ssh/freepackets
fi
eval $(ssh-agent)
ssh-add ~/.ssh/freepackets

echo "Test for ssh key on ${rtr_ip}..."
ssh -o "BatchMode yes" ${rtr_usr}@${rtr_ip} true
if [ $? -ne 0 ] ; then
	echo "install ssh dev key on ${rtr_ip} (even it exists allready)"
	scp dev_key/freepackets.pub ${rtr_usr}@${rtr_ip}:/tmp/freepackets.pub
	ssh ${rtr_usr}@${rtr_ip} 'cat /tmp/freepackets.pub > /etc/dropbear/authorized_keys;chmod 0600 /etc/dropbear/authorized_keys'
else
	echo "OKAY."
fi

for e in $files ; do
	f=$(echo $e | cut -d ";" -f 1)
	d=$(dirname $f)
	p=$(echo $e | cut -d ";" -f 2 -s)
	echo "copy $f..."
	# create dir if needed
	ssh ${rtr_usr}@${rtr_ip} mkdir -p $d
	scp -r ${folder_prefix}/${f} ${rtr_usr}@${rtr_ip}:${f}

	if [ ! -z "${p}" ] ; then
		echo "set permissions $p for $f"
		ssh ${rtr_usr}@${rtr_ip} chmod  ${p} ${f}
	else
		echo "WARNING: no permissions for $f given."
	fi
done

# remove key when finished
# ssh ${rtr_usr}@${rtr_ip} 'rm /etc/dropbear/authorized_keys'


