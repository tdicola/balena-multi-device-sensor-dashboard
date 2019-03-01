#!/bin/bash
# compile_dts.sh will compile all device tree overlay source files into
# dtbo overlay binaries.
# Usage:
#   compile_dtsh. <path to overlay source folder>
set -e

OVERLAYS_DIR=$1

# Loop through all the .dts files in the overlays folder and compile them into
# .dtbo binary overlays with the dtc device tree compiler.
for INPUT_DTS in $(find $OVERLAYS_DIR -name '*.dts'); do
  OUTPUT_DTBO=${INPUT_DTS%.dts}.dtbo
  echo "Compiling overlay DTS: $INPUT_DTS"
  dtc -q -@ -I dts -O dtb -o $OUTPUT_DTBO $INPUT_DTS
done

exit 0
