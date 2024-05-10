# Grub2 UEFI HTTP

- Select bootloader and correct template
- Smart Proxy, enable feature httpboot
- refresh proxy
- subnets -> httpboot proxy

```bash
cd /var/lib/tftpboot/grub2
wget https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/EFI/BOOT/grubx64.efi

chown you:you *.efi
```

```bash
virt-install  --name="super_cool_machine"\
  --ram 4096 \
  --vcpus 4 \
  --connect qemu:///system \
  --network network=fo_pxe_bios_tftp,mac=00:aa:bb:91:91:aa \
  --os-variant centos-stream9 \
  --pxe \
  --noreboot \
  --boot uefi,loader_ro=yes,loader_type=pflash,loader_secure=no,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.fd

```
