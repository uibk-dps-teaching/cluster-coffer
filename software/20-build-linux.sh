#!/bin/sh

#. ./zz-board-cfg.sh
set -eu
IFS=

NPROC=${NPROC:-$(nproc)}
LINUX_TAG=${LINUX_TAG:-v5.1-rc1}

[ -e build/linux.ready ] && exit 0

mkdir -p build

if [ ! -e build/linux/.ready ]; then 
    rm -rf build/linux
    git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git build/linux --depth=1 -b $LINUX_TAG
    touch build/linux/.ready
fi

(
    cd build/linux
    git reset --hard $LINUX_TAG
    git am -- ../../patches/linux/*
)

mkdir -p build/images/kernel/rockchip

cd build/linux

export CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64
make defconfig
./scripts/kconfig/merge_config.sh arch/arm64/configs/defconfig coffer-cluster.config
make deb-pkg -j$NPROC

make kernelrelease > ../images/kernel/version
dcmd cp ../linux-*$(make kernelrelease)*_arm64.changes ../images/kernel

(
	cd ../images/kernel
	apt-ftparchive packages . > Packages
	# cp ./arch/arm64/boot/Image ../images/kernel
	# cp ./arch/arm64/boot/dts/rockchip/rk3399-nanopc-t4.dtb \
	#    ./arch/arm64/boot/dts/rockchip/rk3399-nanopi-m4.dtb \
	#    ../images/kernel/rockchip/
)

touch ../linux.ready
