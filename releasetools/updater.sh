#!/sbin/sh
#
# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2016 The OmniROM Project
# Copyright (C) 2018 Choose-A project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# check mounts
check_mount() {
    local MOUNT_POINT=$(readlink "${1}");
    if ! test -n "${MOUNT_POINT}" ; then
        # readlink does not work on older recoveries for some reason
        # doesn't matter since the path is already correct in that case
        echo "Using non-readlink mount point ${1}";
        MOUNT_POINT="${1}";
    fi
    if ! grep -q "${MOUNT_POINT}" /proc/mounts ; then
        mkdir -p "${MOUNT_POINT}";
        if ! mount -t "${3}" "${2}" "${MOUNT_POINT}" ; then
             echo "Cannot mount ${1} (${MOUNT_POINT}).";
             exit 1;
        fi
    fi
}

# check partitions
check_mount /lta-label /dev/block/bootdevice/by-name/LTALabel ext4;
check_mount /oem /dev/block/bootdevice/by-name/oem ext4;

setvariant=$(\
    cat /system/build.prop | \
    grep ro.sony.variant | \
    sed s/.*=// \
);

# Detect the exact model from the LTALabel partition
# This looks something like:
# 1284-8432_5-elabel-D5303-row.html
variant=$(\
    ls /lta-label/*.html | \
    sed s/.*-elabel-// | \
    sed s/-.*.html// | \
    tr -d '\n\r' | \
    tr '[a-z]' '[A-Z]' \
);

insertvariant() {
if [[ "$variant" == "F8331" ]]
then
    $(echo "ro.sony.variant=${variant}" >> /system/build.prop);
    $(echo "ro.telephony.default_network=9,1" >> /system/build.prop);
    $(echo "ro.product.model=XPeria XZ" >> /system/build.prop);
    $(echo "ro.semc.product.model=F8331" >> /system/build.prop);
    $(echo "ro.semc.version.sw=1302-9162" >> /system/build.prop);
    $(echo "ro.semc.version.sw_variant=GLOBALDS-LTE3D" >> /system/build.prop);
    $(echo "ro.build.description=kagura-user 8.0.0 OPR1.170623.026 1 dev-keys" >> /system/build.prop);
    $(echo "ro.bootimage.build.fingerprint=Sony/kagura/kagura:8.0.0/OPR1.170623.026/1:user/dev-keys" >> /system/build.prop);
else
    $(echo "ro.sony.variant=${variant}" >> /system/build.prop);
    $(echo "persist.multisim.config=dsds" >> /system/build.prop);
    $(echo "persist.radio.multisim.config=dsds" >> /system/build.prop);
    $(echo "ro.telephony.ril.config=simactivation" >> /system/build.prop);
    $(echo "ro.telephony.default_network=9,1" >> /system/build.prop);
    $(echo "ro.product.model=XPeria XZ DualSim" >> /system/build.prop);
    $(echo "ro.semc.product.model=F8332" >> /system/build.prop);
    $(echo "ro.semc.version.sw=1302-9162" >> /system/build.prop);
    $(echo "ro.semc.version.sw_variant=GLOBALDS-LTE3D" >> /system/build.prop);
    $(echo "ro.build.description=kagura_dsds-user 8.0.0 OPR1.170623.026 1 dev-keys" >> /system/build.prop);
    $(echo "ro.bootimage.build.fingerprint=Sony/kagura_dsds/kagura_dsds:8.0.0/OPR1.170623.026/1:user/dev-keys" >> /system/build.prop);
fi
}
        
# Set the variant as a prop
if [[ "$setvariant" == "$variant" ]]
then
    echo "Variant already set!";
else
    insertvariant;
fi
exit 0
