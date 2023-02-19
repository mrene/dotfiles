#!/usr/bin/env bash


check() {
  nix eval ".#${1}.outPath"
}

checkHome() {
  check "homeConfigurations.${1}.${2}.activationPackage"
}

checkHome "aarch64-darwin" "mrene@Mathieus-MBP"
checkHome "x86_64-linux" "mrene@beast"
checkHome "aarch64-linux" "minimal"
checkHome "x86_64-linux" "minimal"
checkHome "aarch64-darwin" "minimal"
checkHome "x86_64-darwin" "minimal"

