#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash alsa-utils

amixer -c Flex set 'miniDSP Flex' 100%
