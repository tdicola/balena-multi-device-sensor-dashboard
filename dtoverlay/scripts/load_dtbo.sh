#!/bin/bash
# load_dtbo.sh script will load a list of device tree overlays.
# Usage:
#   load_dtbo.sh <path to overlays folder> [list of overlays to load]
# For example to load and apply foo.dtbo and bar.dtbo from /var/dtoverlay/overlays:
#   load_dtbo.sh /var/dtoverlay/overlays foo bar
set -e

OVERLAYS_DIR=$1

# Attempt to load the configfs tree for the device tree.
mount -t configfs none /sys/kernel/config
if [ ! -d /sys/kernel/config/device-tree ]; then
  echo load_dtb.sh: Failed to find device tree ConfigFS root under \
       /sys/kernel/config/device-tree. Ensure the kernel has been compiled \
       with device tree ConfigFS support.
  exit -1
fi

# Loop through each of the parameters after the first and attempt to load to
# load them as device tree overlays.
shift
cd $OVERLAYS_DIR
for OVERLAY in "$@"; do
  OVERLAY=${OVERLAY%.dtbo} # Strip off .dtbo if it was specified accidentally.
  OVERLAY_FILE=$OVERLAY.dtbo
  echo "load_dtbo.sh: Loading overlay: $OVERLAY_FILE"
  mkdir -p /sys/kernel/config/device-tree/overlays/$OVERLAY
  cat $OVERLAY_FILE > /sys/kernel/config/device-tree/overlays/$OVERLAY/dtbo
done

echo "load_dtbo.sh: Finished loading overlays!"

exit 0
