#!/usr/bin/env bash

# Note, this script was reimplemented by reference to scripts
# available in https://github.com/kjhoerr/dotfiles
# which at the time of doing this was under the MIT licence:
# https://github.com/kjhoerr/dotfiles/blob/f897c38654218dc51f580ad0c7ad6fddb1d7525b/LICENSE

# Configurables
BTRFS_VOL="@ROOT_DEVICE@"
MOUNTDIR="/mnt"
BLANK_ROOT_SNAPSHOT="root-blank"
ROOT_SUBVOL="root"


# Implementation
mkdir -p "${MOUNTDIR}"

if [ ! -r "${BTRFS_VOL}" ]; then
    >&2 echo "Device '${BTRFS_VOL}' not found"
    exit 1
fi

# Mount the main BTRFS_VOL
mount -t btrfs -o subvol=/ "${BTRFS_VOL}" "${MOUNTDIR}"

# If the blank snapshot does not exist, create it
if [ ! -d "${MOUNTDIR}/${BLANK_ROOT_SNAPSHOT}" ]; then
    btrfs subvolume create "${MOUNTDIR}/${BLANK_ROOT_SNAPSHOT}"
fi

# Next if there's anything inside the root subvolume, clear it out

btrfs subvolume list -o "${MOUNTDIR}/${ROOT_SUBVOL}" |
    cut -f9 -d' ' |
    while read -r subvolume; do
        echo "deleting /$subvolume subvolume"
        echo btrfs subvolume delete "${MOUNTDIR}/${subvolume}"
        btrfs subvolume delete "${MOUNTDIR}/${subvolume}"
    done &&
    echo "deleting root subvolume" &&
    echo btrfs subvolume delete "${MOUNTDIR}/${ROOT_SUBVOL}" &&
    btrfs subvolume delete "${MOUNTDIR}/${ROOT_SUBVOL}"

echo "restoring blank root subvolume"
btrfs subvolume snapshot "${MOUNTDIR}/${BLANK_ROOT_SNAPSHOT}" "${MOUNTDIR}/${ROOT_SUBVOL}"
echo "Unmounting"
umount "${MOUNTDIR}"
echo "Done"

