#!/usr/bin/env bash


check() {
  echo "Checking $1"
  nix eval --raw ".#${1}.outPath" 
}

checkHome() {
  check "homeConfigurations.${1}.${2}.activationPackage" &
}

checkNixos() {
  check "nixosConfigurations.${1}.config.system.build.toplevel" &
}

checkNixos "beast"
checkNixos "utm"

checkHome "aarch64-darwin" "mrene@Mathieus-MBP"
checkHome "x86_64-linux" "mrene@beast"
checkHome "aarch64-linux" "minimal"
checkHome "x86_64-linux" "minimal"
checkHome "aarch64-darwin" "minimal"
checkHome "x86_64-darwin" "minimal"


wait
