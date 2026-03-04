# Virtual BMC & ipmi

Installation
```shell
install -y python-virtualbmc ipmitool
```

List Libvirt machines
```shell
virsh list --all
```

Add virtual BMC to the machine:
```shell
vbmc add <domain> --port 6230 --username admin --password password
vbmcd --foreground
vbmc start <domain>
```

Test the virutal BMC
```shell
ipmitool -I lanplus -U admin -P password -H 127.0.0.1 -p 6230 power on
ipmitool -I lanplus -U admin -P password -H 192.168.66.1 -p 6230 power on
```

Smart Proxy configuration
```yaml
# config/settings.d/bmc.yml
---
:enabled: true
:bmc_default_provider: ipmitool
```
```
