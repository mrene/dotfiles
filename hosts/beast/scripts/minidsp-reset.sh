#!/usr/bin/env bash

DEV=/sys/bus/usb/devices/1-5
MFGR=$(cat $DEV/manufacturer)

if [ ! "$MFGR" == "miniDSP" ]; then
  echo "Unexpected manufacturer: $MFGR"
  exit
fi

PORT=$(readlink -f ${DEV}/port)

echo 1 > ${PORT}/disable
echo 0 > ${PORT}/disable
