# Libvirt network debugging

Where's the problem?

- Libvirt network
- DNS
- Routing
- Firewall
- Apache

## Libvirt network

Run as `root`: `NTW="vagrant-libvirt";virsh net-edit $NTW;virsh net-destroy $NTW; virsh net-start $NTW`

Check that all information is correct

```xml
<network>
  <name>vagrant-libvirt</name>
  <uuid>your-uuid</uuid>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:28:3e:5e'/>
  <dns>
    <host ip='192.168.121.1'>
      <hostname>foreman.local.lan</hostname>
    </host>
  </dns>
  <ip address='192.168.121.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.121.2' end='192.168.121.254'/>
    </dhcp>
  </ip>
</network>
```

```ruby
Vagrant.configure("2") do |config|
  # Do not check update each start, it's too slow
  config.vm.box_check_update = false
  config.vm.network "private_network", type: "dhcp"
end
```

## DNS

**To Internet**

```
ping -4 -c 5 google.com
```

Fix: Run `echo "nameserver 8.8.8.8" > /etc/resolv.conf`

**From guest to the host**

```
ping -4 -c 5 foreman.local.lan
```

Must have this in the network config:

```xml
  <dns>
    <host ip='192.168.121.1'>
      <hostname>foreman.local.lan</hostname>
    </host>
  </dns>
```

## Routing

```
ping -4 -c 5 192.168.121.1
```

Fix: Check the `virbrX` nic on host machine, does it have same IP as you have in the network config?

```xml
<network>
  <ip address='192.168.121.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.121.2' end='192.168.121.254'/>
    </dhcp>
  </ip>
</network>
```

## Firewall

Stop the firewall on both machines and check if the issue is still persistent. If yes, than the problem is not in the firewall.

**TODO:** Some of this is probably not needed, buut I don't remember what exactly.

```
systemctl stop firewalld

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --zone=FedoraWorkstation --add-port=80/tcp --permanent
firewall-cmd --zone=FedoraWorkstation --add-port=443/tcp --permanent

# Starting from RHEL 9, both forward and masquerade options must be enabled on firewalld when forwarding packets from one interface to another.
firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
firewall-cmd --permanent --zone=FedoraWorkstation --add-forward

# Exception rule for Libvirt machines
firewall-cmd --zone=FedoraWorkstation --add-source=192.168.121.1/24 --permanent
firewall-cmd --zone=FedoraWorkstation --add-rich-rule='rule family="ipv4" source address="192.168.121.1/24" accept' --permanent

firewall-cmd --reload
systemctl restart firewalld
```

## Apache

Remove any `/etc/httpd/conf.d/*.conf` files that are not necessary.

See [httpd.conf](/datas/httpd/httpd.conf)
See [foreman.conf](/data/httpd/foreman.conf)
