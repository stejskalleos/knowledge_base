# Debugging

(in this order)

* Foreman
* Services
* Firewall

## Foreman

* Start Foreman
* Start Proxy
* (re)build the host

## Services

**dnsmasq is not running**
```shell
ss -lupn | grep :67

kill -9 PID
```

**Libvirt network is running**
```shell
NET="foreman-isc.lan";virsh net-edit $NET;virsh net-destroy $NET;virsh net-start $NET
```

**DHCP & TFTP**
```
systemctl restart dhcpd tftp; systemctl status dhcpd tftp
```
## Firewall

Move the virbr66 interface to the trusted zone.

^^ Do it after every libvirt network change.
