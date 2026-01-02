#!/usr/bin/env bash

DEV=/sys/bus/usb/devices/$1
MFGR=$(cat $DEV/manufacturer)

PORT=$(readlink -f ${DEV}/port)

echo 1 > ${PORT}/disable
echo 0 > ${PORT}/disable
