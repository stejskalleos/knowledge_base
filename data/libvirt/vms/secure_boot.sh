#!/bin/sh

virt-install  --name="sb_vm" \
  --ram 12000 \
  --vcpus 6 \
  --connect qemu:///system \
  --network network=secure_boot,mac=00:AA:BB:CC:6B:4E \
  --machine q35 \
  --os-variant rhel9.3 \
  --pxe \
  --noreboot \
  --boot uefi,loader_ro=yes,loader_type=pflash,loader_secure=yes,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd,nvram=/var/lib/libvirt/qemu/nvram/sb_vm.fd,loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd \
  --features smm=on
