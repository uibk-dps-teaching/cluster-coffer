#!/bin/sh
. ./zz-board-cfg.sh
DISK=$1; shift

bmaptool create "$DEPLOY_IMAGE" -o "${DEPLOY_IMAGE}.bmap"

echo
echo
echo -n "Please insert MMC for $DISK, press ENTER to continue..."
read _

echo "Flashing $DEPLOY_IMAGE"
bmaptool copy "$DEPLOY_IMAGE" "$DISK"
