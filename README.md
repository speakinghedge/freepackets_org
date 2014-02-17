freepackets_org
===============

This project offers an easy to use firmware based on OpenWRT to setup and run
a public wireless access point. It uses common wireless routers to create
a routing device that splits the offered networks in a public and private
subnetwork. The traffic of the public network is routed over a VPN tunnel
while the private subnet uses a direct connection (to the Internet).

By choosing a VPN server in a place/country that respects privacy (and maybe
a hand full of other basic rights like the freedom of speech), the
access point can serve as anonymous and unrestricted way to the Internet and
all the services offered over that great network.

The firmware implements no logging and (per default) no authentication for the
clients of the public network.

Currently only the good old WRT54GL is supported. I plan to port it to the
TP-Link TL-WR1043ND and D-LINK DIR-615 in the next weeks.

## configure and build the firmware

Each supported platform has its own documentation. You can find it in
<platform>/doc/. Please read it.

The configuration for the VPN tunnel and access point is stored in the
folder *private* inside of the root directory of the project (means: the
configuration is common for all platforms) and contains the following files:
```
- private: contains private configuration used to build the firmware
    |------->password.txt        VPN passwords (mandatory)
    |------->openvpn.ovpn        VPN configuration (mandatory)
    |------->system.conf         system configuration (optional)
```

You can create a folder called private_local to store your personal local 
configuration for the firmware build. To be able to build the firmware image 
you must provide the configuration files in the private or private_local folder. 

**Note 1:** The config placed in the private_local folder supersedes the one 
given in the private folder. The private_folder is ignored by git.

**Note 2:** On checkout the private folder contains a example config that can 
not be used to build a running system.

The password.txt file contains the credentials used for the authentication
against the VPN service. The first line contains the user name, the second
line the password (both in plain text). Sample file:
```
thisistheusername
mysecrectpassword
```

The openvpn.ovpn contains the OpenVPN configuration including the
certificates for ca and client and the private client key. The following
sample is taken form Cyberghost VPN service (you can download the needed
configuration in the support area the certs/keys are stripped out
of course):

```
client
remote se.openvpn.cyberghostvpn.com 9081
dev tun
proto udp
auth-user-pass /etc/openvpn/pass.txt

resolv-retry infinite
redirect-gateway def1
persist-key
persist-tun
nobind
cipher AES-256-CBC
auth MD5
ping 5
ping-exit 60
ping-timer-rem
script-security 3
remote-cert-tls server
route-delay 5
tun-mtu 1500
fragment 1300
mssfix 1300
verb 4
comp-lzo

<ca>
...
</ca>

<cert>
...
</cert>

<key>
...
</key>
```

Not supported options are disabled in the config and you will get a not
about that during the build process.

The optional system.conf can be used to customize the firmware by using the
following configuration parameters:
* ap_ssid - set the ssid of the access point, default: freepackets_org
* ap_pwd  - set the password needed to authenticate for using the wireless AP, default: no password

Sample file:
```
ap_ssid="freepackets_01"
ap_pwd="123456"
```

Accesspoints ssid is freepackets_01, password 123456.

```
ap_ssid="free_internet"
ap_pwd=""
```

Accesspoints ssid is free_internet, no password protection.

Now build the firmware by running build_firmware.sh located in the platforms
root directory. If everything goes well, the firmware images relevant for
your platform are placed in the folder <your platform>/firmware.

On the first start after flashing the firmware with the new firmware an 
automated restart is performed. This is caused by a script that fixes
the system configuration (it is not possible to add packages that overwrite
the stock system config so I had to fix that on first startup).

Flash your device and everything is ready to use. If you want to check that
everything is fine with your access point, use the list of test located in the doc
folder. I think it is not complete at the moment - but it may give you an idea
what to check and how. Feel free to add more tests.

For further information check the doc folder of your platform and have a look
at freepackets.org.

## next steps
* add support for TP-Link TL-WR1043ND
* create statitic interface / package
* convert config to UCI
* create UCI interface

## Todo
* check that iptable rules are sufficient

## Known issues
* spontaneous death of the tunnel - add "manual" keep alive ping?
* config can not be changed over the UCI interface

## Important

The password of the router is not changed during installation of the firmware.

