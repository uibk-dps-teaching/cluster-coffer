#!/bin/sh
set -eu
IFS=

if [ x"$(cat /etc/hostname)" != x"head" ]; then echo Refusing to run on wrong host!; exit 1; fi

echo root:root | chpasswd -c SHA512

# directory to be shared via SMB to all nodes
mkdir /share | true
chmod 777 /share

mkdir -p /srv/rootfs-nanopi-m4
cat > /etc/fstab <<EOF
/dev/mmcblk1p2	/	ext4	defaults,errors=remount-ro 0 0
/dev/mmcblk2p2  /srv/rootfs-nanopi-m4    ext4    defaults,errors=remount-ro,noauto,x-systemd.automount 0 0
#^ we use an automount here so the system can boot when the eMMC has only trash
# on it, for example no partition table.
//127.0.0.1/public	/share    cifs    defaults,user=cc,password=cc,vers=2.0,uid=cc,gid=cc,x-systemd.automount 0 0
EOF

mkdir -p /etc/samba
cat > /etc/samba/smb.conf << EOF
[global]
workgroup = smb
security = user
map to guest = Bad Password

[homes]
comment = Home Directories
browsable = no
read only = no
create mode = 0750

[public]
path = /srv/rootfs-nanopi-m4/share/
writable = yes
comment = smb share
printable = no
guest ok = yes
force user = cc
force group = cc
EOF

echo head > /etc/hostname

cat > /etc/hosts <<EOF
127.0.0.1	localhost
127.0.1.1	head head.c16

172.27.142.100	node00
172.27.142.101	node01
172.27.142.102	node02
172.27.142.103	node03
172.27.142.104	node04
172.27.142.105	node05
172.27.142.106	node06
172.27.142.107	node07
172.27.142.108	node08
172.27.142.109	node09
172.27.142.110	node10
172.27.142.111	node11
172.27.142.112	node12
172.27.142.113	node13
172.27.142.114	node14
172.27.142.115	node15
EOF

cat > /etc/exports <<EOF
/srv/rootfs-nanopi-m4/  172.27.142.0/24(ro,nohide,no_subtree_check,sync,no_root_squash)
EOF

cat > /etc/network/interfaces <<EOF
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

allow-hotplug eth0
iface eth0 inet static
      address 172.27.142.250
      gateway 172.27.142.254
      netmask 255.255.255.0

iface eth0 inet6 auto
EOF

cat > /root/flash-m4-rootfs.sh <<"EOF"
#!/bin/sh
set -ex

# Usage: flash-m4-rootfs [flash|start|stop]

stop () {
    /etc/init.d/nfs-kernel-server stop >&2 </dev/null
    umount /dev/mmcblk2p2 >&2 </dev/null || true
}

start () {
    mount /dev/mmcblk2p2
    /etc/init.d/nfs-kernel-server start
}

flash () {
    stop
    zcat > /dev/mmcblk2       #<<< this consumes stdin
    sync /dev/mmcblk2 </dev/null > /dev/null
    start
}

trap 'start; trap - INT; kill -INT $$' INT
trap 'start; trap - TERM; kill -TERM $$' TERM

if [ $# -eq 0 ]; then
   set -- flash
fi

"$@"
EOF
chmod +x /root/flash-m4-rootfs.sh

env -i apt-get update
env -i DEBIAN_FRONTEND=noninteractive apt-get install -yy -q \
	dnsmasq ntp systemd-sysv initramfs-tools nfs-kernel-server locales util-linux u-boot-menu etckeeper openssh-server rsync libopenmpi-dev build-essential vim emacs-nox cmake gdb valgrind samba cifs-utils

apt-get autoremove && apt-get clean

cat > /etc/dnsmasq.conf <<EOF
local=/c16/
dhcp-range=172.27.142.150,172.27.142.199,12h

enable-tftp
tftp-root=/srv/

# these are just here for consistency, the node's IPs are statically configured
dhcp-host=42:14:b8:a3:a0:00,172.27.142.100,infinite
dhcp-host=42:14:b8:a3:a0:01,172.27.142.101,infinite
dhcp-host=42:14:b8:a3:a0:02,172.27.142.102,infinite
dhcp-host=42:14:b8:a3:a0:03,172.27.142.103,infinite
dhcp-host=42:14:b8:a3:a0:04,172.27.142.104,infinite
dhcp-host=42:14:b8:a3:a0:05,172.27.142.105,infinite
dhcp-host=42:14:b8:a3:a0:06,172.27.142.106,infinite
dhcp-host=42:14:b8:a3:a0:07,172.27.142.107,infinite
dhcp-host=42:14:b8:a3:a0:08,172.27.142.108,infinite
dhcp-host=42:14:b8:a3:a0:09,172.27.142.109,infinite
dhcp-host=42:14:b8:a3:a0:0a,172.27.142.110,infinite
dhcp-host=42:14:b8:a3:a0:0b,172.27.142.111,infinite
dhcp-host=42:14:b8:a3:a0:0c,172.27.142.112,infinite
dhcp-host=42:14:b8:a3:a0:0d,172.27.142.113,infinite
dhcp-host=42:14:b8:a3:a0:0e,172.27.142.114,infinite
dhcp-host=42:14:b8:a3:a0:0f,172.27.142.115,infinite
EOF

# TODO: ssh-keyscan
cat >> /etc/ssh/sshd_config <<EOF
PermitRootLogin yes
EOF

