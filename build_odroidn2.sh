#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

export SOURCE_DATE_EPOCH=$(git -C "../u-boot" log -1 --pretty=%ct HEAD)

BOARD=g12b_odroidn2_v1
FIP_DIR=fip-collect-g12b-odroidn2-odroidg12-v2015.01-20260328-145606
UBOOT_BIN="${SCRIPT_DIR}/uboot-bins/u-boot.bin"

LINEAGE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DEVICE_PATH="${LINEAGE_ROOT}/device/hardkernel/odroidn2"
VENDOR_PATH="${LINEAGE_ROOT}/vendor/hardkernel/odroidn2"

[[ -d "${VENDOR_PATH}" ]] && mkdir -p "${VENDOR_PATH}/radio"

./build.sh "$BOARD"
./generate-bins-new.sh "$FIP_DIR" ../u-boot/build/u-boot.bin "${BOARD}-base"
[[ -d "${VENDOR_PATH}" ]] && cp "$UBOOT_BIN" "${VENDOR_PATH}/radio/bootloader.img"

if [[ -d "${DEVICE_PATH}" ]]; then
    cd "$DEVICE_PATH" && ./setup-makefiles.py
fi
if [[ -d "${VENDOR_PATH}" ]]; then
    cd "$VENDOR_PATH"
    SHA_HEAD=$(git -C "${SCRIPT_DIR}/../u-boot" rev-parse HEAD)
    git add -A
    git commit -m "odroidn2: Update bootloader image prebuilt" \
               -m "Generated as of ${SHA_HEAD}"
fi
