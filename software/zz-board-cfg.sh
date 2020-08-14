#!/bin/sh

#Usage: $0 BOARD <INDEX> DISK

set -eu
set -x
IFS=

BOARD=$1; shift
case "$BOARD" in
    *t4) 
	INDEX=255
	HOST=head
	NETBOOT=false
	IMAGE=build/images/$BOARD/$BOARD-disk.img
	UBOOT_IMAGE=$IMAGE
	DEPLOY_IMAGE=$IMAGE
	;;
    *m4) 
	INDEX=$1; shift
	HOST=nodeXX
	NETBOOT=true
	IMAGE=build/images/$BOARD/$BOARD-rootfs.img
	UBOOT_IMAGE=build/images/$BOARD/$BOARD-disk$(printf '%02d' $INDEX).img
	DEPLOY_IMAGE=$UBOOT_IMAGE
	;;
esac

export HOST
export INDEX_HEX=$(printf '%02x' $INDEX)
export INDEX_IP=$(printf '%d' $(($INDEX + 100)))
