#!/bin/sh

. ./zz-board-cfg.sh

# U-boot
########

if $NETBOOT; then
    
    # This is mostly just the default u-boot config! Just the first two lines,
    # prefix= and bootcmd= are custom. Unfortunately the u-boot env image
    # completely replaces the builtin env instead of just overriding.
    #
    # To reproduce run the following in the u-boot tree after building:
    #     ./scripts/get_default_envs.sh .
    cat > build/images/$BOARD/u-boot.env <<"EOF"
prefix=rootfs-nanopi-m4
bootcmd=tftp $kernel_addr_r $serverip:$prefix/vmlinuz && tftp $ramdisk_addr_r $serverip:$prefix/initrd.img && set ramdisk_size ${filesize} && tftp $fdt_addr_r $serverip:$prefix/dtb/$fdtfile && set bootargs root=/dev/nfs ro nfsroot=$serverip:/srv/$prefix/ ip=$ipaddr:$serverip:$gateway:$netmask:nanopx-x4::off nfsrootdebug console=ttyS2,${baudrate}n8 && booti $kernel_addr_r $ramdisk_addr_r:${ramdisk_size} $fdt_addr_r
arch=arm
baudrate=1500000
board=evb_rk3399
board_name=evb_rk3399
boot_a_script=load ${devtype} ${devnum}:${distro_bootpart} ${scriptaddr} ${prefix}${script}; source ${scriptaddr}
bootcmd_dhcp=run boot_net_usb_start; if dhcp ${scriptaddr} ${boot_script_dhcp}; then source ${scriptaddr}; fi;setenv efi_fdtfile ${fdtfile}; setenv efi_old_vci ${bootp_vci};setenv efi_old_arch ${bootp_arch};setenv bootp_vci PXEClient:Arch:00011:UNDI:003000;setenv bootp_arch 0xb;if dhcp ${kernel_addr_r}; then tftpboot ${fdt_addr_r} dtb/${efi_fdtfile};if fdt addr ${fdt_addr_r}; then bootefi ${kernel_addr_r} ${fdt_addr_r}; else bootefi ${kernel_addr_r} ${fdtcontroladdr};fi;fi;setenv bootp_vci ${efi_old_vci};setenv bootp_arch ${efi_old_arch};setenv efi_fdtfile;setenv efi_old_arch;setenv efi_old_vci;
bootcmd_mmc0=devnum=0; run mmc_boot
bootcmd_mmc1=devnum=1; run mmc_boot
bootcmd_pxe=run boot_net_usb_start; dhcp; if pxe get; then pxe boot; fi
bootcmd_usb0=devnum=0; run usb_boot
bootdelay=2
boot_efi_binary=if fdt addr ${fdt_addr_r}; then bootefi bootmgr ${fdt_addr_r};else bootefi bootmgr ${fdtcontroladdr};fi;load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} efi/boot/bootaa64.efi; if fdt addr ${fdt_addr_r}; then bootefi ${kernel_addr_r} ${fdt_addr_r};else bootefi ${kernel_addr_r} ${fdtcontroladdr};fi
boot_extlinux=sysboot ${devtype} ${devnum}:${distro_bootpart} any ${scriptaddr} ${prefix}${boot_syslinux_conf}
boot_net_usb_start=usb start
boot_prefixes=/ /boot/
boot_script_dhcp=boot.scr.uimg
boot_scripts=boot.scr.uimg boot.scr
boot_syslinux_conf=extlinux/extlinux.conf
boot_targets=mmc0 mmc1 usb0 pxe dhcp 
cpu=armv8
distro_bootcmd=for target in ${boot_targets}; do run bootcmd_${target}; done
efi_dtb_prefixes=/ /dtb/ /dtb/current/
fdtfile=rockchip/rk3399-nanopi-m4.dtb
fdt_addr_r=0x01f00000
kernel_addr_r=0x02080000
load_efi_dtb=load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}${efi_fdtfile}
mmc_boot=if mmc dev ${devnum}; then devtype=mmc; run scan_dev_for_boot_part; fi
partitions=uuid_disk=${uuid_gpt_disk};name=loader1,start=32K,size=4000K,uuid=${uuid_gpt_loader1};name=loader2,start=8MB,size=4MB,uuid=${uuid_gpt_loader2};name=trust,size=4M,uuid=${uuid_gpt_atf};name=boot,size=112M,bootable,uuid=${uuid_gpt_boot};name=rootfs,size=-,uuid=B921B045-1DF0-41C3-AF44-4C6F280D3FAE;
pxefile_addr_r=0x00600000
ramdisk_addr_r=0x04000000
scan_dev_for_boot=echo Scanning ${devtype} ${devnum}:${distro_bootpart}...; for prefix in ${boot_prefixes}; do run scan_dev_for_extlinux; run scan_dev_for_scripts; done;run scan_dev_for_efi;
scan_dev_for_boot_part=part list ${devtype} ${devnum} -bootable devplist; env exists devplist || setenv devplist 1; for distro_bootpart in ${devplist}; do if fstype ${devtype} ${devnum}:${distro_bootpart} bootfstype; then run scan_dev_for_boot; fi; done; setenv devplist
scan_dev_for_efi=setenv efi_fdtfile ${fdtfile}; for prefix in ${efi_dtb_prefixes}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${efi_fdtfile}; then run load_efi_dtb; fi;done;if test -e ${devtype} ${devnum}:${distro_bootpart} efi/boot/bootaa64.efi; then echo Found EFI removable media binary efi/boot/bootaa64.efi; run boot_efi_binary; echo EFI LOAD FAILED: continuing...; fi; setenv efi_fdtfile
scan_dev_for_extlinux=if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${boot_syslinux_conf}; then echo Found ${prefix}${boot_syslinux_conf}; run boot_extlinux; echo SCRIPT FAILED: continuing...; fi
scan_dev_for_scripts=for script in ${boot_scripts}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${script}; then echo Found U-Boot script ${prefix}${script}; run boot_a_script; echo SCRIPT FAILED: continuing...; fi; done
scriptaddr=0x00500000
soc=rockchip
usb_boot=usb start; if usb dev ${devnum}; then devtype=usb; run scan_dev_for_boot_part; fi
vendor=rockchip
EOF

    cat >> build/images/$BOARD/u-boot.env <<EOF
ethaddr=42:14:b8:a3:a0:$INDEX_HEX
ipaddr=172.27.142.$INDEX_IP
netmask=255.255.255.0
serverip=172.27.142.250
EOF

    build/u-boot/tools/mkenvimage \
	-s 0x8000 \
	-o build/images/$BOARD/u-boot.env.img build/images/$BOARD/u-boot.env

    rm -f "$UBOOT_IMAGE"; qemu-img create "$UBOOT_IMAGE" 32M
fi


dd if=build/images/$BOARD/spl_mmc.img of="$UBOOT_IMAGE" seek=64 conv=notrunc
if $NETBOOT; then
    dd if=build/images/$BOARD/u-boot.env.img of="$UBOOT_IMAGE" seek=8128 conv=notrunc
fi
dd if=build/images/$BOARD/u-boot.itb of="$UBOOT_IMAGE" seek=16384 conv=notrunc


