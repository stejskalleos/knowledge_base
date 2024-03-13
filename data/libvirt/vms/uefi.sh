#!/bin/sh

virt-install  --name="uefi_vm"\
  --ram 12000 \
  --vcpus 4 \
  --connect qemu:///system \
  --network network=uefi,mac=00:AA:BB:CC:5B:30 \
  --os-variant rhel9.3 \
  --pxe \
  --noreboot \
  --boot uefi,loader_ro=yes,loader_type=pflash,loader_secure=no,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.fd
