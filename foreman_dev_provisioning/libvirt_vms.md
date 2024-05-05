# Libvirt virtual machines

## PXE, BIOS, TFTP

```bash
virt-install \
  --name=centos-stream9-vm \
  --vcpus=4 \
  --memory=4096 \
  --disk size=20 \
  --os-variant=centos-stream9 \
  --network "network=fo_pxe_bios_tftp,mac=00:aa:bb:90:90:cc" \
  --connect qemu:///system \
  --pxe
```
