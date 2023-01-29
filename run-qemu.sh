 #!/bin/bash

DISPLAY_OPTS="-display gtk -vga virtio"
FS_OPTS="-virtfs local,path=/home/mrene,security_model=none,mount_tag=home"
MEMORY="-m 8192 -device virtio-balloon"

export QEMU_OPTS="${DISPLAY_OPTS} ${FS_OPTS} ${MEMORY}" 
 
nixos-generate -f vm --flake ".#beast" --run