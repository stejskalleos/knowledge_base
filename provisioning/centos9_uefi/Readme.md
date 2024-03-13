# UEFI provisioning with Libvirt

CentOS stream 9

## Packages

Make sure that all files in `/usr/share/edk2/ovmf` are present

```
sudo dnf reinstall edk2-ovmf
```

## Data

Linux kernel and InitRAM disk

```console
cd boot/centos_9

wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/images/pxeboot/initrd.img
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/images/pxeboot/vmlinuz
```

Grub loader and Shim

```console
cd boot
wget https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/EFI/BOOT/grubx64.efi
sudo cp /boot/efi/EFI/fedora/shimx64.efi .
sudo chown $USER: *.efi
```

## Libvirt network

```console
virsh net-edit default
```

Configure network same way as in `data/libvirt_network.xml`

Apply the changes

```console
virsh net-destroy default; virsh net-start default
```

## HTTP server

Run the HTTP server

```console
python3 -m http.server
```

Check that all files are in the right place

```
http://0.0.0.0:8000/

├── boot
│   ├── centos_9
│   │   ├── initrd.img
│   │   ├── ks.cfg
│   │   └── vmlinuz
│   ├── grub.cfg
│   ├── grubx64.efi
│   └── shimx64.efi
├── data
│   └── libvirt_network.xml
└── Readme.md
```

(optional) Validate `ks.cfg`

```console
ksvalidator boot/centos_9/ks.cfg
```

## Spin up the VM

Without SecureBoot

```
virt-install  --name="efi_vm"\
  --ram 4096 \
  --vcpus 2 \
  --connect qemu:///system \
  --network network=default,mac=00:AA:BB:CC:5B:30 \
  --os-variant centos-stream9 \
  --pxe \
  --noreboot \
  --boot uefi,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.fd,loader_secure=no
```

With SecureBoot

```console
TODO: With current shims and grubx, SecureBoot doesn't.
```
