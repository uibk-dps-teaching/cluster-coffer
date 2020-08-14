#!/bin/sh
set -eu
IFS=

echo root:root | chpasswd -c SHA512

# directory to be shared via SMB to all nodes
mkdir /share | true
chmod 777 /share

cat > /etc/fstab <<EOF
# needs to be "rw" for obscure initrd reasons, see init-bottom/root-ro
172.27.142.250:/srv/rootfs-nanopi-m4	/	nfs	defaults,rw 0 0
//172.27.142.250/public	/share    cifs    defaults,user=cc,password=cc,vers=2.0,uid=cc,gid=cc,x-systemd.automount 0 0
EOF

cat > /etc/hosts <<EOF
127.0.0.1	localhost
127.0.1.1	$HOST $HOST.c16
172.27.142.250	head head.c16
EOF

cat > /etc/network/interfaces <<EOF
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

allow-hotplug eth0

# # The IP is assigned at boot time, with the ip= kernel param. We need that for
# NFSroot anyways, the manual section below is just in case:
iface eth0 inet manual
       address 172.27.142.42
       gateway 172.27.142.254
       netmask 255.255.255.0
iface eth0 inet6 auto
EOF

env -i apt-get update
env -i DEBIAN_FRONTEND=noninteractive apt-get install -yy -q \
	systemd-sysv \
	initramfs-tools \
	locales \
	util-linux \
	etckeeper \
	ntp \
	openssh-server \
	libopenmpi-dev \
	vim \
	cifs-utils

apt-get autoremove && apt-get clean

# NTP configuration - sync time from head node only, remove all pool entries
sed -i '/pool [0-9]/d' /etc/ntp.conf
cat >> /etc/ntp.conf <<EOF
server 172.27.142.250 iburst
EOF

mkdir -p /etc/initramfs-tools/scripts/init-bottom
cat > /etc/initramfs-tools/modules <<EOF
overlay
EOF

cat > /etc/initramfs-tools/initramfs.conf <<EOF
#
# initramfs.conf
# Configuration file for mkinitramfs(8). See initramfs.conf(5).
#
# Note that configuration options from this file can be overridden
# by config files in the /etc/initramfs-tools/conf.d directory.

#
# MODULES: [ most | netboot | dep | list ]
#
# most - Add most filesystem and all harddrive drivers.
#
# dep - Try and guess which modules to load.
#
# netboot - Add the base modules, network modules, but skip block devices.
#
# list - Only include modules from the 'additional modules' list
#

MODULES=netboot

#
# BUSYBOX: [ y | n | auto ]
#
# Use busybox shell and utilities.  If set to n, klibc utilities will be used.
# If set to auto (or unset), busybox will be used if installed and klibc will
# be used otherwise.
#

BUSYBOX=y

#
# KEYMAP: [ y | n ]
#
# Load a keymap during the initramfs stage.
#

KEYMAP=n

#
# COMPRESS: [ gzip | bzip2 | lz4 | lzma | lzop | xz ]
#

COMPRESS=gzip

#
# NFS Section of the config.
#

BOOT=nfs

#
# DEVICE: ...
#
# Specify a specific network interface, like eth0
# Overridden by optional ip= or BOOTIF= bootarg
#

DEVICE=

#
# NFSROOT: [ auto | HOST:MOUNT ]
#

NFSROOT=auto

#
# RUNSIZE: ...
#
# The size of the /run tmpfs mount point, like 256M or 10%
# Overridden by optional initramfs.runsize= bootarg
#

RUNSIZE=10%
EOF

cat > /etc/initramfs-tools/scripts/init-bottom/root-ro <<"EEEOF"
#!/bin/sh
#
#  Read-only Root-FS for Raspian
#
#  Modified 2015 by Pascal Rosin to work on raspian-ua-netinst with
#  overlayfs integrated in Linux Kernel >= 3.18.
#
#  Originally written by Axel Heider (Copyright 2012) for Ubuntu 11.10.
#  This version can be found here:
#  https://help.ubuntu.com/community/aufsRootFileSystemOnUsbFlash#Overlayfs
#
#  Based on scripts from
#    Sebastian P.
#    Nicholas A. Schembri State College PA USA
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.
#
#
# Changelog:
#
# v1.0.0
#   - written by Axel Heider for Ubuntu 11.10
#
# v2.0.0
#   - Modified to work with overlayfs integrated in Linux Kernel (>= 3.18)
#   - introduce workdir needed for new overlayfs
#   - change `mount --move` to `mount -o move` to drop busybox requirement
#   - Tested with raspian-ua-netinst v1.0.7
#     (Linux 3.18.0-trunk-rpi, Debian 3.18.5) on a Raspberry Pi.
#     The aufs part is not tested!
#
# Notes:
#   * no changes to the root fs are made by this script.
#   * if /home/[user] is on the RO root fs, files are in ram and not saved.
#
# Install:
#  put this file in /etc/initramfs-tools/scripts/init-bottom/root-ro
#  chmod 0755 /etc/initramfs-tools/scripts/init-bottom/root-ro
#  update-initramfs -u
#  add `root-ro-driver=overlay` to the line in /boot/cmdline.txt
#
# Disable read-only root fs
#   * option 1: kernel boot parameter "disable-root-ro=true"
#   * option 2: create file "/disable-root-ro"
#
# ROOT_RO_DRIVER variable controls which driver isused for the ro/rw layering
#   Supported drivers are: overlayfs, aufs
#  the kernel parameter "root-ro-driver=[driver]" can be used to initialize
#  the variable ROOT_RO_DRIVER. If nothing is given, overlayfs is used.
#

# no pre requirement
PREREQ=""

prereqs()
{
    echo "${PREREQ}"
}

case "$1" in
    prereqs)
    prereqs
    exit 0
    ;;
esac

# import /usr/share/initramfs-tools/scripts/functions
. /scripts/functions

MYTAG="root-ro"
DISABLE_MAGIC_FILE="/disable-root-ro"

# parse kernel boot command line
ROOT_RO_DRIVER=
DISABLE_ROOT_RO=
for CMD_PARAM in $(cat /proc/cmdline); do
    case ${CMD_PARAM} in
        disable-root-ro=*)
            DISABLE_ROOT_RO=${CMD_PARAM#disable-root-ro=}
            ;;
        root-ro-driver=*)
            ROOT_RO_DRIVER=${CMD_PARAM#root-ro-driver=}
            ;;
    esac
done

# check if read-only root fs is disabled
if [ ! -z "${DISABLE_ROOT_RO}" ]; then
    log_warning_msg "${MYTAG}: disabled, found boot parameter disable-root-ro=${DISABLE_ROOT_RO}"
    exit 0
fi
if [ -e "${rootmnt}${DISABLE_MAGIC_FILE}" ]; then
    log_warning_msg "${MYTAG}: disabled, found file ${rootmnt}${DISABLE_MAGIC_FILE}"
    exit 0
fi

# generic settings
# ${ROOT} and ${rootmnt} are predefined by caller of this script. Note that
# the root fs ${rootmnt} it mounted readonly on the initrams, which fits nicely
# for our purposes.
ROOT_RO=/mnt/root-ro
ROOT_RW=/mnt/root-rw
ROOT_RW_UPPER=${ROOT_RW}/upper
ROOT_RW_WORK=${ROOT_RW}/work

# check if ${ROOT_RO_DRIVER} is defined, otherwise set default
if [ -z "${ROOT_RO_DRIVER}" ]; then
    ROOT_RO_DRIVER=overlay
fi
# settings based in ${ROOT_RO_DRIVER}, stop here if unsupported.
case ${ROOT_RO_DRIVER} in
    overlay)
        MOUNT_PARMS="-t overlay -o lowerdir=${ROOT_RO},upperdir=${ROOT_RW_UPPER},workdir=${ROOT_RW_WORK} overlay ${rootmnt}"
        ;;
    aufs)
        MOUNT_PARMS="-t aufs -o dirs=${ROOT_RW}:${ROOT_RO}=ro aufs-root ${rootmnt}"
        ;;
    *)
        panic "${MYTAG} ERROR 1: invalid ROOT_RO_DRIVER ${ROOT_RO_DRIVER}"
        ;;
esac


# check if kernel module exists
modprobe -qb ${ROOT_RO_DRIVER}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 2: missing kernel module ${ROOT_RO_DRIVER}"
    exit 0
fi

# make the mount point on the init root fs ${ROOT_RW}
[ -d ${ROOT_RW} ] || mkdir -p ${ROOT_RW}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 3: failed to create ${ROOT_RW}"
    exit 0
fi

# make the mount point on the init root fs ${ROOT_RO}
[ -d ${ROOT_RO} ] || mkdir -p ${ROOT_RO}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 4: failed to create ${ROOT_RO}"
    exit 0
fi

# make the mount point on the init root fs ${ROOT_WORKDIR}
[ -d ${ROOT_WORKDIR} ] || mkdir -p ${ROOT_WORKDIR}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 5: failed to create ${ROOT_WORKDIR}"
    exit 0
fi


# mount a tempfs using the device name tmpfs-root at ${ROOT_RW}
mount -t tmpfs tmpfs-root ${ROOT_RW}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 6: failed to create tmpfs"
    exit 0
fi

if [ "${ROOT_RO_DRIVER}" = "overlay" ]; then

    [ -d ${ROOT_RW_UPPER} ] || mkdir -p ${ROOT_RW_UPPER}
    if [ $? -ne 0 ]; then
        log_failure_msg "${MYTAG} ERROR 6.1: failed to create ${ROOT_RW_UPPER}"
        exit 0
    fi

    [ -d ${ROOT_RW_WORK} ] || mkdir -p ${ROOT_RW_WORK}
    if [ $? -ne 0 ]; then
        log_failure_msg "${MYTAG} ERROR 6.2: failed to create ${ROOT_RW_WORK}"
        exit 0
    fi

fi


# root is mounted on ${rootmnt}, move it to ${ROOT_RO}.
mount -o move ${rootmnt} ${ROOT_RO}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 7: failed to move root away from ${rootmnt} to ${ROOT_RO}"
    exit 0
fi

# there is nothing left at ${rootmnt} now. So for any error we get we should
# either do recovery to restore ${rootmnt} for drop to a initramfs shell using
# "panic". Otherwise the boot process is very likely to fail with even more
# errors and leave the system in a wired state.

# mount virtual fs ${rootmnt} with rw-fs ${ROOT_RW} on top or ro-fs ${ROOT_RO}.
mount ${MOUNT_PARMS}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 8: failed to create new ro/rw layerd ${rootmnt}"
    # do recovery and try resoring the mount for ${rootmnt}
    mount -o move ${ROOT_RO} ${rootmnt}
    if [ $? -ne 0 ]; then
       # thats bad, drop to shell to let the user try fixing this
       panic "${MYTAG} RECOVERY ERROR: failed to move ${ROOT_RO} back to ${rootmnt}"
    fi
    exit 0
fi

# now the real root fs is on ${ROOT_RO} of the init file system, our layered
# root fs is set up at ${rootmnt}. So we can write anywhere in {rootmnt} and the
# changes will end up in ${ROOT_RW} while ${ROOT_RO} it not touched. However
# ${ROOT_RO} and ${ROOT_RW} are on the initramfs root fs, which will be removed
# an replaced by ${rootmnt}. Thus we must move ${ROOT_RO} and ${ROOT_RW} to the
# rootfs visible later, ie. ${rootmnt}${ROOT_RO} and ${rootmnt}${ROOT_RO}.
# Since the layered ro/rw is already up, these changes also end up on
# ${ROOT_RW} while ${ROOT_RO} is not touched.

# move mount from ${ROOT_RO} to ${rootmnt}${ROOT_RO}
[ -d ${rootmnt}${ROOT_RO} ] || mkdir -p ${rootmnt}${ROOT_RO}
mount -o move ${ROOT_RO} ${rootmnt}${ROOT_RO}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 9: failed to move ${ROOT_RO} to ${rootmnt}${ROOT_RO}"
    exit 0
fi

# move mount from ${ROOT_RW} to ${rootmnt}${ROOT_RW}
[ -d ${rootmnt}${ROOT_RW} ] || mkdir -p ${rootmnt}${ROOT_RW}
mount -o move ${ROOT_RW} ${rootmnt}${ROOT_RW}
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG}: ERROR 10: failed to move ${ROOT_RW} to ${rootmnt}${ROOT_RW}"
    exit 0
fi

# technically, everything is set up nicely now. Since ${rootmnt} had beend
# mounted read-only on the initfamfs already, ${rootmnt}${ROOT_RO} is it, too.
# Now we init process could run - but unfortunately, we may have to prepare
# some more things here.
# Basically, there are two ways to deal with the read-only root fs. If the
# system is made aware of this, things can be simplified a lot.
# If it is not, things need to be done to our best knowledge.
#
# So we assume here, the system does not really know about our read-only root fs.
#
# Let's deal with /etc/fstab first. It usually contains an entry for the root
# fs, which is no longer valid now. We have to remove it and add our new
# ${ROOT_RO} entry.
# Remember we are still on the initramfs root fs here, so we have to work on
# ${rootmnt}/etc/fstab. The original fstab is ${rootmnt}${ROOT_RO}/etc/fstab.
ROOT_TYPE=$(cat /proc/mounts | ${rootmnt}/bin/grep ${ROOT} | ${rootmnt}/usr/bin/cut -d' ' -f3)
ROOT_OPTIONS=$(cat /proc/mounts | ${rootmnt}/bin/grep ${ROOT} | ${rootmnt}/usr/bin/cut -d' ' -f4)
cat <<EOF >${rootmnt}/etc/fstab
#
#  This fstab is in RAM, the real one can be found at ${ROOT_RO}/etc/fstab
#  The original entry for '/' and all swap files have been removed.  The new
#  entry for the read-only the real root fs follows. Write access can be
#  enabled using:
#    sudo mount -o remount,rw ${ROOT_RO}
#  re-mounting it read-only is done using:
#    sudo mount -o remount,ro ${ROOT_RO}
#

${ROOT} ${ROOT_RO} ${ROOT_TYPE} ${ROOT_OPTIONS} 0 0

#
#  remaining entries from the original ${ROOT_RO}/etc/fstab follow.
#
EOF
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 11: failed to modify /etc/fstab (step 1)"
    #exit 0
fi

#remove root entry and swap from fstab
cat ${rootmnt}${ROOT_RO}/etc/fstab | ${rootmnt}/bin/grep -v ' / ' | ${rootmnt}/bin/grep -v swap >>${rootmnt}/etc/fstab
if [ $? -ne 0 ]; then
    log_failure_msg "${MYTAG} ERROR 12: failed to modify etc/fstab (step 2)"
    #exit 0
fi

# now we are done. Additinal steps may be necessary depending on the actualy
# distribution and/or its configuration.

log_success_msg "${MYTAG} sucessfully set up ro/tmpfs-rw layered root fs using ${ROOT_RO_DRIVER}"

exit 0
EEEOF
chmod 755 /etc/initramfs-tools/scripts/init-bottom/root-ro

cat >> /etc/ssh/sshd_config <<EOF
PermitRootLogin yes
EOF

