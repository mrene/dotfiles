#!/usr/bin/env bash

check() {
  echo "Checking $1"
  nix eval --raw ".#${1}.outPath"
}

checkNixos() {
  check "nixosConfigurations.${1}.config.system.build.toplevel" &
}

checkDarwin() {
  check "darwinConfigurations.${1}.config.system.build.toplevel" &
}

checkNixos beast
checkNixos nas
checkNixos utm
checkNixos wsl
checkNixos tvpi

checkDarwin mbpm3
checkDarwin mbp2021

wait
