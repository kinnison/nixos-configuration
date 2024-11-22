#!/usr/bin/env bash

# Note, this script was reimplemented by reference to scripts
# available in https://github.com/kjhoerr/dotfiles
# which at the time of doing this was under the MIT licence:
# https://github.com/kjhoerr/dotfiles/blob/f897c38654218dc51f580ad0c7ad6fddb1d7525b/LICENSE

# Configurables
BTRFS_VOL="@ROOT_DEVICE@"
BLANK_ROOT_SNAPSHOT="root-blank"
ROOT_SUBVOL="root"

# Implementation

if [ "$(id -u)" != "0" ]; then
    >&2 echo Cannot continue, please run as root
    exit 1
fi

MOUNTDIR=$(mktemp -d)
cleanup () { umount "${MOUNTDIR}"; rmdir "${MOUNTDIR}"; }
trap 0 cleanup

if [ ! -r "${BTRFS_VOL}" ]; then
    >&2 echo "Device '${BTRFS_VOL}' not found"
    exit 1
fi

# Mount the main BTRFS_VOL
mount -t btrfs -o subvol=/ "${BTRFS_VOL}" "${MOUNTDIR}"

# If the blank snapshot does not exist, we have a problem.
if [ ! -d "${MOUNTDIR}/${BLANK_ROOT_SNAPSHOT}" ]; then
    >&2 echo "Unfortunately I cannot find the blank root snapshot"
    exit 1
fi

# Determine the transaction ID belonging to the blank snapshot
BASE_TRANSID=$(btrfs subvolume find-new "${MOUNTDIR}/${BLANK_ROOT_SNAPSHOT}" | tr -dc '[:digit:]')

btrfs subvolume find-new "${MOUNTDIR}/${ROOT_SUBVOL}" "${BASE_TRANSID}" |
    sed '$d' |
    cut -f17- -d' ' |
    sort |
    uniq |
    while read -r path; do
        abspath="/${path}"
        if [ -L "${abspath}" ]; then
            : # Symbolic link, probably NixOS, so ignore
        elif [ -d "${abspath}" ]; then
            : # Directory, we don't care about it
        else
            echo "${abspath}"
        fi
    done

# Falling off the end, the trap above cleans up
