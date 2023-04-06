#!/usr/bin/env bash
#
DEV=$1
HOST=$2

parted $DEV -- mklabel gpt
parted $DEV -- mkpart primary 512MB -8GB
parted $DEV -- mkpart primary linux-swap -8GB 100%

parted $DEV -- mkpart ESP fat32 1MB 512MB
parted $DEV -- set 3 esp on

mkfs.ext4 -L nixos ${DEV}1
mkswap -L swap ${DEV}
mkfs.fat -F 32 -n boot ${DEV}3

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/${DEV}2

nixos-generate-config --root /mnt --dir ./nixos/${HOST}

