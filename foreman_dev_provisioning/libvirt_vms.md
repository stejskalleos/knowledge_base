# Libvirt virtual machines

## PXE via TFTP

```bash
virt-install \
  --name=centos-stream9-vm \
  --vcpus=4 \
  --memory=4096 \
  --disk size=20 \
  --os-variant=centos-stream9 \
  --network "network=fo_pxe_bios_tftp,mac=00:aa:bb:90:90:90" \
  --connect qemu:///system \
  --pxe \
  --firmware /home/lstejska/projects/seabios/out/bios.bin
```

## iPXE via HTTP

```bash
virt-install \
  --name=centos-stream9-vm \
  --vcpus=4 \
  --memory=4096 \
  --disk size=20 \
  --os-variant=centos-stream9 \
  --network "network=fo_pxe_bios_tftp,mac=00:aa:bb:91:91:aa" \
  --connect qemu:///system \
  --pxe
```
