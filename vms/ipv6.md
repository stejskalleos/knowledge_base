# IPv6 with Vagrant & Libvirt
## Forklift
`vagrant/boxes.d/99-local.yaml`
```yaml
---
centos9-katello-devel-stable:
  box_name: katello/katello-devel
  memory: 16384
  cpus: 6
  hostname: centos9-katello-devel-stable.example.com
  networks:
    - type: 'private_network'
      options:
        ip: 192.168.66.66
        libvirt__guest_ipv6: "yes"
```
Spinup the machine and check the network configuration:
```
ip a

ens7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:b8:4c:f4 brd ff:ff:ff:ff:ff:ff
    altname enp0s7
    inet 192.168.66.66/24 brd 192.168.66.255 scope global noprefixroute ens7
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:feb8:4cf4/64 scope link 
       valid_lft forever preferred_lft forever
```

## Your virtual machines
`Vagrantfile
```ruby
config.vm.network "private_network",
  ip: "192.168.123.#{rand(2..254)}",
  libvirt__guest_ipv6: "yes"

```

## SSH
```shell
ssh root@fe80::5054:ff:fe6e:5e14%eth1
```
(You need to specify the interface because it's a local link IPv6)
