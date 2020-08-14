#!/bin/sh

#. ./zz-board-cfg.sh
set -eu
IFS=

NPROC=${NPROC:-$(nproc)}

[ -e build/u-boot.ready ] && exit 0

mkdir -p build

if [ ! -e build/u-boot/.ready ]; then 
    rm -rf build/u-boot
    git clone https://github.com/u-boot/u-boot build/u-boot
    # git://git.denx.de/u-boot.git

    (
	cd build/u-boot
	git checkout 6a08213d52f036dbfbdd92f1416bc4b08fd4d3f6
	git checkout -b dps-coffer-cluster
	git am -- ../../patches/u-boot/*
	touch .ready
    )
fi

if [ ! -e build/arm-trusted-firmware/.ready ]; then
    rm -rf build/arm-trusted-firmware
    git clone https://github.com/ARM-software/arm-trusted-firmware.git -b v2.0 build/arm-trusted-firmware
    touch build/arm-trusted-firmware/.ready
fi

(
    cd build/arm-trusted-firmware
    make CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3399 bl31 -j$NPROC
    cp build/rk3399/release/bl31/bl31.elf ../u-boot
)

mkdir -p build/images/nanopi-m4 build/images/nanopc-t4

build_uboot () (
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    cd build/u-boot

    make distclean; rm -f spl_*.img
    make $1_defconfig
    make all u-boot.itb -j$NPROC

    tools/mkimage -n rk3399 -T rksd    -d spl/u-boot-spl-dtb.bin spl_mmc.img

    cp spl_mmc.img u-boot.itb ../images/$1
)

build_uboot nanopc-t4
build_uboot nanopi-m4

printf '\n\n'
printf 'Built %s\n' build/images/nanopi-m4/* build/images/nanopc-t4/*

touch build/u-boot.ready
