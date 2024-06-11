#!/usr/bin/env sh

# Original credits go to koshigoe. See https://gist.github.com/koshigoe/822455
#
# This program has three features.
#
# 1. Create a disk image on RAM.
# 2. Mount that disk image.
# 3. Copy over an encrypted archive and prompt the user to decrypt it.
#
# Usage:
#   $0 [archive] [location] [name]
#
#   archive:
#     The archive encoded in tar encrypted by age. Defaults to "Data.tar.gz.age"
#   location:
#     The mount location. Defaults to the scripts-location/mount
#   name:
#     The name of the archive that'll be displayed in Finder, this is a friendly name. Defaults to "Temporary Archive"
#
# See also:
#   - hdid(8)
#   - hdiutil(1)
#

archive=${1:-Data.tar.gz.age}
base_loc=$(dirname "$0")/mount
mount_point=${2:-$base_loc}
size=64 # 64 MB
sector=$(expr $size \* 1024 \* 1024 / 512)
name=${3:-"Temporary Archive"}

code=0

# Creates the mount point
if ! mkdir -p "$mount_point"; then
    code=$?
    echo "The mount point directory didn't succeed" >&2
    exit $code
fi

# Created the temporary fs in RAM
device_name=$(hdiutil attach -nomount "ram://${sector}" | awk '{print $1}')
code=$? #This is weird behaviour but must be done according to ShellCheck
if [ $code -ne 0 ]; then
    echo "Could not create disk image." >&2
    exit $code
fi
code=0

# Formats the newly created temporary fs to use hfs+
if ! newfs_hfs -v "$name" "$device_name" > /dev/null; then
    code=$?
    echo "Could not format disk image." >&2
    exit $code
fi

# Mounts the partition
if ! mount -t hfs "$device_name" "$mount_point"; then
    code=$?
    echo "Could not mount disk image." >&2
    exit $code
fi

# Unarchives the encrypted archive
if ! age -d "$archive" | tar x --cd "$mount_point"; then
    code=$?
    echo "Could not unarchive encrypted archive." >&2
    exit $code
fi
