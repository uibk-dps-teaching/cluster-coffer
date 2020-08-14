Cofferware
==========

WARNING: This script clobbers. It doesn't try to do error handling and will just
remove stuff that's in the way at the start. It will remove all lodevs with
`losetup -D` and forcefully unmounts whatever is at /mnt. It will probably eat
your system whole. So read the source carefully luke or use a disposable VM :)

Dependencies
------------

    $ apt-get install build-essential qemu-user-static qemu-utils debootstrap \
        devscripts util-linux e2fsprogs zerofree bmap-tools jq pv \
        gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
        gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi \
        python-pyelftools \
        device-tree-compiler
    $ apt-get build-dep linux

SSH Keys
--------

Before executing the scripts, generate SSH keys for the cluster and put them
inside the `ssh_keys` folder. It should look like this when finished:

    software/ssh_keys/
    ├── cc/
    │   ├── id_ed25519
    │   └── id_ed25519.pub
    ├── host_keys/
    │   ├── ssh_host_ecdsa_key
    │   ├── ssh_host_ecdsa_key.pub
    │   ├── ssh_host_ed25519_key
    │   ├── ssh_host_ed25519_key.pub
    │   ├── ssh_host_rsa_key
    │   └── ssh_host_rsa_key.pub
    └── root/
        ├── id_ed25519
        └── id_ed25519.pub

Building and Deploying
----------------------

Let's get started. First find your SD reader block device and put it's path into
`$DISK`. Preferably you should use the persistent device symlinks from
`/dev/disk/by-id`:

    $ DISK=/dev/disk/by-id/<SD/MMC reader blockdevice>

Next, copy the `root` private ssh key to your local machine in order 
to be able to connect to the head node: 

    $ cp ssh_keys/root/id_ed25519 ~/.ssh/

The `do-board-sequence.sh` script runs the numbered scripts in this repo top to
bottom with the configuration given on the commandline.

When it gets to the `90-deploy-image.sh` script it will prompt you to make sure
the appropriate SD card is inserted in `$DISK`.

For the head node:

    $ sudo sh do-board-sequence.sh nanopc-t4 $DISK
    [...build output...]
    
    Please insert MMC for $DISK, press ENTER to continue...
    Flashing build/images/nanopc-t4/nanopc-t4-disk.img
    bmaptool: info: discovered bmap file 'build/images/nanopc-t4/nanopc-t4-disk.img.bmap'
    bmaptool: info: block map format version 2.0
    bmaptool: info: 3145728 blocks of size 4096 (12.0 GiB), mapped 314749 blocks (1.2 GiB or 10.0%)
    bmaptool: info: copying image 'nanopc-t4-disk.img' to block device '$DISK' using bmap file 'nanopc-t4-disk.img.bmap'
    bmaptool: info: 100% copied
    bmaptool: info: synchronizing '$DISK'
    bmaptool: info: copying time: 21m 0.2s, copying speed 999.0 KiB/sec

For the compute nodes we'll run the same script in a loop. You'll be prompted
before the SD card is accessed so you have time to swap in a new card:

    $ for i in seq 0 15; do \
        sudo sh do-board-sequence.sh nanopi-m4 $i $DISK

Don't worry the disk images for the compute nodes are only a couple of megabytes
in size since they boot via network, so this should go fairly quickly.

Build products are in `./build/`.

U-boot and finished disk-images land in `./build/images/{nanopc-t4,nanopi-m4}/`
Shared kernel packages land in `./build/images/kernel`

#### Compute node rootfs

After the ordeal of flashing all the compute nodes we now just need to copy
their rootfs to the eMMC/NVMe storage on the head node.

Just connect to the head node via ethernet. If DHCP works, good, otherwise give
your computer an IP in the `172.27.142.200-240` range.

So for example:

    root@my-workstation$ ip addr add dev eth0 172.27.142.200/24

Next we run the actual copy job. We use `gz -1` as a simple way to avoid copying
zero blocks since the image is sparse.

    root@my-workstation$ pv build/images/nanopi-m4/nanopi-m4-rootfs.img | gzip -1 - | ssh root@172.27.142.250 /root/flash-m4-rootfs.sh
      12GiB 0:04:29 [45.6MiB/s] [========================================>] 100%

Now sit back, relax and enjoy the nice `pv(1)` progress bar.

Controller Setup
--------------------------

The controller machine should simply connect via any port on the switch. The 
nodes have the gateway IP `172.27.142.254` hardcoded, which should be the 
connector machine or a router that forwards packets from/to your network.

You can also get an IP by just connecting to the switch, the head node has a
DHCP server running.

Running stuff
-----------------------------

The non-root user for normal operations is called `cc` and must be used for 
e.g. starting MPI applications. A somewhat recent version of MPI should be in 
`PATH`, so you can test whether everything works by ssh'ing to the machine, 
switching to user `cc` and executing your program.

    $ ssh root@172.27.142.250 # (or the external IP of your router)
    $ su cc
    $ mpirun -np 2 /bin/hostname

For MPI, a custom default hosts file is provided in 
`/etc/openmpi/openmpi-default-hostfile`.

Furthermore, for sharing executables and data among the nodes, the head node
serves as a samba server, with a common directory `/share` available on all
nodes and mounted upon first access.

Installing additional packages
-----------------------------

#### Compute nodes

To install packages on the compute node we have to modify it's rootfs which is
stored on the head node.

    root@head$ chroot /srv/rootfs-nanopi-m4/ /bin/bash
    root@nodeXX$ apt-get install <whatever>

#### Time Sync APT Problems

If you get errors like these

```
    # apt-get update
    Hit:1 http://cdn-fastly.deb.debian.org/debian buster InRelease
    Reading package lists... Done
    E: Release file for http://deb.debian.org/debian/dists/buster/InRelease is not valid yet (invalid for another 364d 20h 29min 5s). Updates for this repository will not be applied.
```

The machine's time is off. APT relies on time synchronization to prevent
rollback attacks, but our SBCs don't have RTC clocks. If the NTP daemon on the 
head node is running properly and has internet access, everything should work 
fine but if that's not the case we can just manually bring the time back into
slack.

On a computer with a reliable (ish) time, run:

    $ date -R
    Thu, 28 Mar 2019 12:53:08 +0100

Copy that string and on each node to be synchronized, run:

    $ date -s 'Thu, 28 Mar 2019 12:53:08 +0100'

That should bring things in sync enough for apt not to complain.

BUGS
----

- Head node gets stuck on reboot/reset with MMC read errors, sucess might depend
  on SD Card:

```
U-Boot SPL board init
Trying to boot from MMC1
mmc_load_image_raw_sector: mmc block read error
```

- Compute nodes can't cleanly reboot because of systemd trying to save random
  seed to disk after unmounting nfsroot. TODO: Add an ordering dependency

- You have to use the `nodeXX` hostnames for ssh if you don't want to get
  prompted about the hostkey, especially for MPI! This is because we use a
  wildcard in `/etc/ssh/ssh_known_hosts`.

- When you use an SD card previosly occupied by a compute node for the head node
  the u-boot environment block on the card will not get overwritten by bmaptool

To fix this just clear away the u-boot env and write the image to the card
again. The env is in the first 32M or so on the card:

    sudo dd if=/dev/zero of=$DISK bs=4k count=8k status=progress

This is necessary as we use `bmaptool` to speed up the SD card writing
process. However this tool completely skips blocks which are zero. The compute
node images ship a pre-set u-boot env block but the head node simply relies on
the u-boot defaults. This means the environment block in the head node image is
all zeros hence this problem.

FIX: just prepare the env block for the head node too, see 31-install-u-boot.sh.
