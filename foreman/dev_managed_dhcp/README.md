# Foreman - Baremetal DEV environment provisioning

Local development setup for simulating bare-metal provisioning in environments where Foreman is not directly accessible from the machines, but only via Smart Proxy.

## Preconditions
* Running foreman DEV setup
* Running Smart Proxy DEV setup
* [Installed virtualization](https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/)
* (optional) [HTTPS & DEV ENV](https://github.com/stejskalleos/knowledge_base/blob/main/foreman/https_dev_env.md)

**Tools**

* Libvirt for virtual machines (our 'baremetals') & subnet configuration
* [ISC DHCP](https://www.isc.org/dhcp/)
* DNS

**Smart Proxy features**

* DHCP
* DNS
* TFTP
* Registration
* Facts
* Templates

**Data**
* Domain: `foreman-isc.lan`
* Subnet: `192.168.66.1`
* Provisioning interface: `virbr66`

## Libvirt subnet
See the `libvirt/foreman-isc.lan.xml` for the network configuration.

```
virsh net-create ./foreman-isc.lan.xml
virsh net-define ./foreman-isc.lan.xml
virsh net-autostart foreman-isc.lan

virsh net-info foreman-isc.lan
```

## Firewall

```shell
firewall-cmd --change-interface virbr66 --zone trusted
firewall-cmd --change-interface virbr66 --zone trusted --permanent
nmcli connection modify virbr66 connection.zone trusted
```

## TFTP

```shell
dnf install -y syslinux
mkdir -p /var/lib/tftpboot
mkdir -p /var/lib/tftpboot/{boot,grub,grub2,pxelinux.cfg}

cp /usr/share/syslinux/{pxelinux.0,menu.c32,chain.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot

# Change file owner to your account
chown your-account:your-group -R /var/lib/tftpboot
```

## DHCP

### Installation

```
dnf install dhcp-server
```

### Configuration

Configure the `/etc/dhcp/dhcpd.conf`
See the `dhcp/dhcpd.conf` file.

### Service

```
cp /usr/lib/systemd/system/dhcpd.service /etc/systemd/system/dhcpd.service
```

Find the line starting with `ExecStart= `and add the interface name at the end of this line. It should look like this:

```
# /etc/systemd/system/dhcpd.service

...

[Service]
ExecStart=/usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf virbr66 -user dhcpd -group dhcpd --no-pid $DHCPDARGS

...
```

The `virbr66` is the interface for your virtual machines. You don't want the DHCP server to listen everywhere, otherwise you gonna have a bad time.

Start the `dhcpd` service

```
sudo systemctl enable dhcpd.service
sudo systemctl start dhcpd.service
```

Check the status

```
systemctl status dhcpd.service
```

### Last steps

Add yourself to the `dhcpd` group:

```
usermod -a -G dhcpd $USER
chown $USER:dhcpd -R /etc/dhcp
```

### Troubleshooting

```
tail -f /var/log/messages
journalctl -fxeu dhcpd.service
```

Leases file
```
/var/lib/dhcpd/dhcpd.leases
```

### DNS

Installation

```
dnf install dnsmasq
```

Configuration (see `dns/dnsmasq.conf`)
```
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.BAK
vim /etc/dnsmasq.conf
```

## Smart Proxy

Add all the configuration files in the `smart-proxy/config/settings.d/`
(See the sample files in `smart_proxy` directory.)

## Foreman

* Refresh features on Smart Proxy
* Create the domain & assign DNS proxy
```
foreman-isc.lan
```
* Create the subnet
```
Name: default
Network Address: 192.168.66.0
Network Prefix: 24
Network Mask: 255.255.255.0
Gateway Address: 192.168.66.1
Primary DNS server: 192.168.66.1
IPAM: DHCP
Start of IP range: 192.168.66.2
End of IP range: 192.168.66.254
MTU: 1500
Boot mode: DHCP
Proxies tab: Set all to your Smart Proxy
Domains tab: foreman-isc.lan
```
* _Hosts > Operating Systems_ - Create new OS
```
Name: CentOS_Stream
Major Version: 10
Family: Red Hat
Architectures: x86_64
Partition table: Kickstart default
Installation media: CentOS Stream 9 mirror
```
* _Hosts > Provisioning templates_ - Assign templates to the OS
  . PXELinux template: `Kickstart default PXELinux` (`name = "Kickstart default PXELinux"`)
  . Provisioning template: `Kickstart default` (`name = "Kickstart default"`)
* _Hosts > Operating Systems_ - Set default templates and partition table for the OS
* _Infrastructure > Compute Resources_ - Create compute resource for Libvirt
```
Name: Libvirt
Provider: Libvirt
URL: qemu:///system
```
