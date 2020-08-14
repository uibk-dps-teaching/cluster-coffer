#!/bin/sh

. ./zz-board-cfg.sh

umount -R -l /mnt || true
losetup -D

[ -e ${IMAGE}.ready ] && exit 0

mkdir -p $(dirname "$IMAGE")
rm -f "$IMAGE"* && qemu-img create "$IMAGE" 12G

LODEV=$(losetup -f --show "$IMAGE")

mkfs () {
    wipefs -a "$1"
    mkfs.ext4 "$1"
}

if $NETBOOT; then
BOOTABLE=""
else
BOOTABLE="*"
fi
sfdisk --wipe always --wipe-partitions always "$LODEV" <<-EOF
	label: mbr	
	32k, 16M  , L,
	   ,      , L, $BOOTABLE
EOF

partprobe -s "$LODEV"
udevadm settle

PART_TABLE=$(sfdisk -d -J "$LODEV" | jq -r '.partitiontable.partitions')

UBOOT_PART=$(printf '%s\n' "$PART_TABLE" | jq -r '.[0].node')
ROOT_PART=$(printf '%s\n' "$PART_TABLE" | jq -r '.[1].node')

mkfs "${ROOT_PART}"
mount -t ext4 "${ROOT_PART}" /mnt

if [ ! -e build/rootfs.ready ]; then
    rm -rf build/rootfs
    mkdir -p build/rootfs
    
    qemu-debootstrap --arch=arm64 buster build/rootfs http://deb.debian.org/debian
    touch build/rootfs.ready
fi

cp -a build/rootfs/. /mnt

echo $HOST > /mnt/etc/hostname

chroot /mnt sh < setup-$BOARD-system.sh

#
##### kernel
#
kver=$(cat build/images/kernel/version)
dcmd cp -v build/images/kernel/linux-*${kver}*_arm64.changes /mnt/root
chroot /mnt sh -c "dpkg -i /root/linux-image-${kver}_${kver}*_arm64.deb"
chroot /mnt sh -c "update-initramfs -c -k ${kver}"

# Ugh HACK, TODO: use /etc/kernel/postinst.d to do this properly
ln -sf boot/vmlinuz-$kver /mnt/vmlinuz
ln -sf boot/initrd.img-$kver /mnt/initrd.img
ln -sf usr/lib/linux-image-$kver /mnt/dtb

#
##### NTP configuration - force sync upon boot
#
cat >> /mnt/etc/systemd/system/ntp_force_sync.service <<EOF
[Unit]
Description=Force NTP Sync upon boot
Before=ntp.service

[Service]
ExecStart=/usr/sbin/ntpd -q -g
Type=oneshot
#RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

chroot /mnt sh <<EOF
systemctl daemon-reload
systemctl enable ntp_force_sync.service
EOF

#
##### ssh access and non-root ping
#
chroot /mnt sh <<EOF
useradd --user-group --create-home -s /bin/bash cc
mkdir -p /home/cc/.ssh; chmod 700 /home/cc/.ssh
mkdir -p /root/.ssh; chmod 700 /root/.ssh
EOF

cp ssh_keys/cc/* /mnt/home/cc/.ssh/
cat ssh_keys/cc/*.pub >> /mnt/home/cc/.ssh/authorized_keys
cp ssh_keys/root/* /mnt/root/.ssh/
cat ssh_keys/root/*.pub >> /mnt/root/.ssh/authorized_keys

cp ssh_keys/host_keys/* /mnt/etc/ssh/

chroot /mnt sh <<EOF
chmod 600 /home/cc/.ssh/*
chown -R cc:cc /home/cc/.ssh
chmod 600 /root/.ssh/*
chmod 600 /etc/ssh/ssh_host_*
chmod 644 /etc/ssh/ssh_host_*.pub

# add host keys to known hosts; note: allows to connect to ANY host with these host keys
ls -l /etc/ssh/ssh_host_*.pub
for keyfile in /etc/ssh/ssh_host_*.pub ; do echo -n "* " >> /etc/ssh/ssh_known_hosts ; cat \$keyfile >> /etc/ssh/ssh_known_hosts ; done
chmod 644 /etc/ssh/ssh_known_hosts

# enable non-root to use ping
chmod u+s /bin/ping
EOF

#
##### MPI default hosts configuration
#
for i in `seq 0 15` ; do echo "node`printf %02d $i` slots=2 max_slots=6"; done > /mnt/etc/openmpi/openmpi-default-hostfile

umount -R /mnt
losetup -d "$LODEV"

touch ${IMAGE}.ready

