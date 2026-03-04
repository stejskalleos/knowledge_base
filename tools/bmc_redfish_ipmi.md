# BMC, RedFish & IPMI

## Virtual BMC

https://github.com/openstack/virtualbmc

### Installation

Fedora 43
```shell
dnf install python3-virtualbmc
```

Packages
* `vbmcd` - daemon that exposes virtual BMCs
* `vbmc` -  client used for configuration of `vbmcd`

### Running
```
vbmcd --foreground

vbmc add bmc2 --address 0.0.0.0 --username root --password dog8code --libvirt-uri qemu:///syst
vbmc start bmc2

ipmitool -I lanplus -H 127.0.0.1 -U root -P dog8code power status
ipmitool -I lanplus -H 127.0.0.1 -U root -P dog8code power on
ipmitool -I lanplus -H 127.0.0.1 -U root -P dog8code power off
```
