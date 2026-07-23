# KEA 3.0.z & Foreman DEV

Tested on Fedora 43. Using Libvirt (without `DnsMasq`) for bare metal provisioning.

**Key data**

* CentOS 10 where the machine is running
* Provisioning interface: `virbr66`
* Network: `192.168.66.1`

## Preparation

My Libvirt network
```xml
<network>
  <name>foreman-isc.lan</name>
  <uuid>2764fd7d-c437-6666-b76d-484dfb0e933e</uuid>
  <forward mode='nat'/>
  <bridge name='virbr66' stp='on' delay='0'/>
  <mac address='52:54:00:82:ba:15'/>
  <ip address='192.168.66.1' netmask='255.255.255.0'>
  </ip>
</network>
```

## Installation

Repository

```shell
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-3-0/setup.rpm.sh' \
  | sudo -E bash
```

Kea

```shell
dnf install kea
```

## Configuration


