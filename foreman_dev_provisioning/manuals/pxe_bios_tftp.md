# Foreman Provisioning - PXE BIOS TFTP

## TFTP

### Installation

Follow https://fedoramagazine.org/how-to-set-up-a-tftp-server-on-fedora/

### Files

```bash
mkdir -p /var/lib/tftpboot
mkdir -p /var/lib/tftpboot/{boot,grub,grub2,pxelinux.cfg}
cp /usr/share/syslinux/{pxelinux.0,menu.c32,chain.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot
# Change file owner to your account
chown your-account:your-group -R /var/lib/tftpboot
```

## Libvirt Network

```bash
virsh net-create --file networks/fo_pxe_bios_tftp.xml
virsh net-define --file networks/fo_pxe_bios_tftp.xml
virsh net-autostart fo_pxe_bios_tftp
virsh net-info fo_pxe_bios_tftp
```

Note: To apply any changes to the network you must run:

```bash
virsh net-edit fo_pxe_bios_tftp;virsh net-destroy fo_pxe_bios_tftp;virsh net-start fo_pxe_bios_tftp
```

## /etc/hosts

```
127.0.0.1       localhost foreman.local.lan
::1             localhost foreman.local.lan
0.0.0.0         foreman.local.lan
```

## Firewall

```bash
firewall-cmd --change-interface virbr90 --zone trusted
firewall-cmd --change-interface virbr90 --zone trusted --permanent
nmcli connection modify virbr90 connection.zone trusted
firewall-cmd --reload
```

## Foreman Smart Proxy

`config/settings.d/templates.yml`

```yaml
---
:enabled: true
:template_url: http://192.168.190.1:8080
```

`config/settings.d/tftp.yml`

```yaml
---
:enabled: true
:tftproot: /var/lib/tftpboot/
:tftp_servername: 192.168.190.1
```

## Foreman

- Create Operating System

```
Name: CentOS_Stream
Major Version: 9
Family: Red Hat
Architectures: x86_64
Partition table: Kickstart default
Installation media: CentOS Stream 9 mirror
```

- _Hosts > Provisioning templates_ - Assign templates to the OS
  . PXELinux template: `Kickstart default PXELinux` (`name = "Kickstart default PXELinux"`)
  . Provisioning template: `Kickstart default` (`name = "Kickstart default"`)
  . Finish template: `Kickstart default finish` (`name = "Kickstart default finish"`)
- _Hosts > Operating Systems_ - Set default templates and partition table for the OS
