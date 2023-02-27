#!/usr/bin/env bash


check() {
  echo "Checking $1"
  nix eval --raw ".#${1}.outPath" 
}

checkHome() {
  check "home.${1}.${2}.activationPackage" &
}

checkNixos() {
  check "nixosConfigurations.${1}.config.system.build.toplevel" &
}

checkDarwin() {
  check "darwinConfigurations.${1}.config.system.build.toplevel" &
}

checkNixos "beast"
checkNixos "utm"
checkDarwin "Mathieus-MBP"

#checkHome "aarch64-darwin" "mac"
#checkHome "x86_64-linux" "beast"

#checkHome "aarch64-linux" "minimal"
#checkHome "x86_64-linux" "minimal"
#checkHome "aarch64-darwin" "minimal"
#checkHome "x86_64-darwin" "minimal"

wait
