#!/usr/bin/env bash

if [[ -z "$CREATE_FIRMWARE" ]]; then
  echo "Error: This script should be run within the create_firmware.sh environment."
  exit 1
fi

set -eo pipefail

MOONRAKER_CONF="$ROOTFS_DIR/home/lava/origin_printer_data/config/moonraker.conf"
MOONRAKER_INCLUDE='[include extended/moonraker/*.cfg]'

if [[ ! -f "$MOONRAKER_CONF" ]]; then
  echo "Error: Moonraker config not found at $MOONRAKER_CONF."
  exit 1
fi

if ! grep -Fq "$MOONRAKER_INCLUDE" "$MOONRAKER_CONF"; then
  {
    echo
    echo "$MOONRAKER_INCLUDE"
  } >> "$MOONRAKER_CONF"
fi
