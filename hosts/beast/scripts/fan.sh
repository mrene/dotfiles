#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash i2c-tools dmidecode

HWMON=/sys/bus/platform/devices/nct6775.2592/hwmon/hwmon*


function pwm_off() {
    echo 0 | tee ${HWMON}/pwm{3,4,5,6}_enable
    echo 0 | tee ${HWMON}/pwm{3,4,5,6}
}

function pwm_on() {
    echo 5 | tee ${HWMON}/pwm{3,4,5,6}_enable
}

function dc_mode() {
  # Set CPU fans to PWM and the rest to DC
  i2cset -y 0 0x26 0x02 0x03
}

function pwm_mode() {
  # Set all fans to PWM
  i2cset -y 0 0x26 0x02 0xFF
}


if [ "$1" == "on" ]; then
  pwm_mode
  pwm_on
elif [ "$1" == "off" ]; then
  pwm_off
  dc_mode
else
  echo "Usage: $0 {on|off}"
  exit 1
fi
