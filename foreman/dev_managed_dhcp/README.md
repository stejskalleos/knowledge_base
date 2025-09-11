# Foreman - Baremetal DEV environment provisioning

Local development setup for simulating bare-metal provisioning in environments where Foreman is not directly accessible from the machines, but only via Smart Proxy.

## Preconditions
* Running Foreman
* Running Smart Proxy
* [Installed virtualization](https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/)
* Installed WireShark (for network trafic analysis)
* (optional) [HTTPS & DEV ENV](https://github.com/stejskalleos/knowledge_base/blob/main/foreman/https_dev_env.md)

**Tools**

* Libvirt for virtual machines (our 'baremetals') & subnet configuration
* [ISC DHCP](https://www.isc.org/dhcp/) for `DHCP`
* [ISC Bind](https://www.isc.org/bind/) for `DNS`

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

### Create the network
```shell
sudo virsh net-create ./foreman-isc.lan.xml
sudo virsh net-define ./foreman-isc.lan.xml
sudo virsh net-autostart foreman-isc.lan

sudo virsh net-info foreman-isc.lan
```

### Firewall

```shell
sudo firewall-cmd --change-interface virbr66 --zone trusted
sudo firewall-cmd --change-interface virbr66 --zone trusted --permanent
sudo firewall-cmd --zone=libvirt --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```
Note: On my Fedora I have bug where I have to change the `trusted` zone through UI manually, every time.

## TFTP
### Installation
```shell
sudo dnf install tftp-server
sudo systemctl enable --now tftp.socket
sudo systemctl status tftp.socket
```

### Directories
```shell
sudo mkdir -p /var/lib/tftpboot
sudo mkdir -p /var/lib/tftpboot/{boot,grub,grub2,pxelinux.cfg}
```

### Bootloaders
```shell
sudo dnf install -y syslinux
sudo cp /usr/share/syslinux/{pxelinux.0,menu.c32,chain.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot
```

### Permissions
```shell
sudo chown your-account:your-group -R /var/lib/tftpboot

sudo semanage fcontext -a -t tftpdir_t "/var/lib/tftpboot(/.*)?"
sudo restorecon -R -v /var/lib/tftpboot/
```

### Firewall
```shell
sudo firewall-cmd --add-service=tftp --permanent
sudo firewall-cmd --reload
```

## DHCP

### Installation

```shell
sudo dnf install dhcp-server
```

### Configuration

Configure the `/etc/dhcp/dhcpd.conf`
See the `dhcp/dhcpd.conf` file.

### Service

```shell
sudo systemctl edit dhcpd
```

Add the following content:
```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf virbr66 -user dhcpd -group dhcpd --no-pid $DHCPDARGS
```

The `virbr66` is the interface for your virtual machines. You don't want the DHCP server to listen everywhere, otherwise you gonna have a bad time.

Start the `dhcpd` service

```shell
sudo systemctl enable --now dhcpd.service
```

Check the status

```shell
sudo systemctl status dhcpd.service
```

### Last steps

Add yourself to the `dhcpd` group:

```shell
usermod -a -G dhcpd $USER
chown $USER:dhcpd -R /etc/dhcp
```

## DNS

### Installation

```shell
sudo dnf install -y bind bind-utils
```

### Configuration

```shell
cp /etc/named.conf /etc/named.conf.BAK
touch /var/named/dynamic/foreman-isc.lan.db
```

Edit the `/etc/named.conf` same as the `dns/named.conf`.

### Zone files

```shell
mkdir -p /var/named/dynamic
```

Edit the `/var/named/dynamic/foreman-isc.lan.db` same as `dns/foreman-isc.lan.db`
Edit the `/var/named/dynamic/66.168.192.in-addr.arpa.db` same as `66.168.192.in-addr.arpa.db`


### Permissions

```shell
sudo chown -R named:named /var/named/dynamic
sudo usermod -a -G named your-account
sudo chmod g+rw /var/run/named/named.pid /var/run/named/session.key
```

TODO: I had to logout to apply the changes to my account

### Service

```shell
sudo ystemctl enable --now named
sudo systemctl status named
```

## Smart Proxy
Enable and configure following features:

* DHCP
* DNS
* Dynflow
* Facts
* Registration
* Templates
* TFTP

example configurations files are in the `smart_proxy/settings.d` directory.


## Foreman

* Refresh features on Smart Proxy
* Import subnet from Smart Proxy, make sure data is correct:
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
* Create the domain & assign DNS proxy
```
foreman-isc.lan
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

* _Hosts > Templates > Provisioning templates_ **Build PXE Default**

## Provisioning the host

### Create the host in Foreman

```
Compute resource: Bare metal
OS: CentOS Stream 10
Subnet: 192.168.66.1
MAC: 0A:AA:BB:CC:DD:01
Domain: foreman-isc.lan
```

### Running bare-metal
Now we are going to run the virtual machine, representing our bare metal machine.

```shell
virt-install  --name="my-bare-metal" \
  --ram 8192 \
  --vcpus 4 \
  --connect qemu:///system \
  --network network=foreman-isc.lan,mac=0A:AA:BB:CC:DD:01 \
  --os-variant centos-stream10 \
  --pxe
```

## Troubleshooting and Debugging
https://community.theforeman.org/t/debugging-provisioning/32952

### Network traffic
```
sudo wireshark -ki virbr66
```

### TFTP

```shell
tftp 192.168.66.1
get pxelinux.0
quit

# Check if the file has been downloaded (size is not 0)
ls pxelinux.0
```

### DNS

```shell
TODO
```

### DHCP

```shell
tail -f /var/log/messages
journalctl -fxeu dhcpd.service
```

Leases file
```shell
/var/lib/dhcpd/dhcpd.leases
```

### Errors

#### Fetching kickstart from Foreman/Smart Proxy

```shell
Warning: anaconda: failed to fetch kickstart from http://your-smart-proxy/unattende ...
```

Solution: Check your firewall and verify that `virbr66` is in `trusted` zone

## TODO
* Add diagram for bare-metal
* DNS DHCP debugging
