# RHEL 9 SecureBoot with Libvirt

## Prerequisities

- RHEL9 Local repo
- SecureBoot network
- Firewall configured

## Run VM

```
virt-install  --name="efi_vm" \
  --ram 8192 \
  --vcpus 4 \
  --connect qemu:///system \
  --network network=secure_boot,mac=00:aa:bb:cc:f7:62 \
  --machine q35 \
  --os-variant rhel9.3 \
  --pxe \
  --noreboot \
  --boot uefi,loader_ro=yes,loader_type=pflash,loader_secure=yes,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd,nvram=/var/lib/libvirt/qemu/nvram/efi_vm.fd,loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd \
  --features smm=on
```

## Verify SecureBoot is enabled

```
 mokutil --sb-state
 # => SecureBoot enabled
```
