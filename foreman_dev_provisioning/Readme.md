# Foreman provisioning development setup

Follow the tutorial in this order:

1. Prerequisities
1. DHCP
1. [PXE+BIOS+TFTP](manuals/pxe_bios_tftp.md)
1. PXE+UEFI+HTTP

- HTTPboot
- SecureBoot
- With Katello

Bare-metal workflow is simulated with Libvirt.

## Prerequisities

- Tested on Fedora 39
- Ruby 3.0

```
dnf install -y syslinux @virtualization grub2-efi-x64 shim-x64 tftp-server tftp syslinux-tftpboot dhcp-server
```

Check that `libvirtd` is running

```
systemctl enable --now libvirtd
systemctl status libvirtd
```

## Useful tools

### WireShark

```
sudo dnf install wireshark
sudo usermod -a -G wireshark $USER
```

## Firewall

```
firewall-cmd --zone=FedoraWorkstation --add-port=69/udp --permanent

firewall-cmd --reload
```
