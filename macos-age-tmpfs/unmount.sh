#!/usr/bin/env sh

# Original credits go to koshigoe. See https://gist.github.com/koshigoe/822455
#
# This program has two features.
#
# 1. Unmount a disk image.
# 2. Detach the disk image from RAM.
#
# Usage:
#   $0 [dir] [delete]
#
#   dir:
#     The `dir' is a directory, the dir is mounting a disk image. Defaults to the scripts-location/mount
#   delete:
#     True (Yy) or false to delete the mount point directory. Defaults to true
#
# See also:
#   - hdid(8)
#

base_loc=$(dirname "$0")/mount
mount_point=${1:-$base_loc}
delete=${2:-"Y"}

code=0

# Checks mount point
if [ ! -d "${mount_point}" ]; then
    echo "The mount point doesn't exist." >&2
    exit 1
fi
mount_point=$(cd "$mount_point" && pwd) # Gets the full path of mount_point
cd ..

device_name=$(df "${mount_point}" 2>/dev/null | tail -1 | grep "${mount_point}" | cut -d' ' -f1)
if [ -z "${device_name}" ]; then
    echo "Couldn't find device name from mount point. The mount point maybe didn't mount the disk image?" >&2
    exit 1
fi

# Unmounts the mount point
if ! umount "${mount_point}"; then
    code=$?
    echo "Could not unmount." >&2
    exit $code
fi

# Detaches the storage medium from RAM
if ! hdiutil detach -quiet "$device_name"; then
    code=$?
    echo "Could not detach from RAM." >&2
    exit $code
fi

# Checks if to delete the mount point
if [ "$delete" = "Y" ] || [ "$delete" = "y" ]; then
    # Attempts to delete the mount point
    if ! rm "$mount_point"; then
        code=$?
        echo "Problem encountered removing mount point"
        exit $code
    fi
fi
