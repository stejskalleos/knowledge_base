# Managed DHCP

## Installation & configuration

```
dnf install dhcp-server
```

Add configuration for your subnet

```
# /etc/dhcp/dhcpd.conf

See the dhcpd.conf
```

## Service

```
cp /usr/lib/systemd/system/dhcpd.service /etc/systemd/system/dhcpd.service
```

Find the line starting with `ExecStart= `and add the interface name at the end of this line. It should look like this:

```
# vim /etc/systemd/system/dhcpd.service

...

[Service]
ExecStart=/usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf virbr90 -user dhcpd -group dhcpd --no-pid $DHCPDARGS

...
```

The `virbr90` is the interface for your virtual machines. You don't want the DHCP server to listen everywhere, otherwise you gonna have a bad time.

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
chown -R $USER:$USER /etc/dhcp
```

### Troubleshooting

```
tail -f /var/log/messages
journalctl -fxeu dhcpd.service

cat /var/lib/dhcpd/dhcpd.leases
```

## Smart Proxy

Add configuration files in `smart-proxy/config/settings.d/`

- `config/settings.d/dhcp.yml`
- `config/settings.d/dhcp_isc.yml`

See the sample files in `TODO` directory.

## Foreman

- _Infrastructure > Domains_ - Create `virtual.lan`
- _Infrastructure > Smart Proxies_ - Refresh & verify that all features are correctly loaded
- _Infrastructure > Smart Proxies_ - Import IPv4 subnets & create new `TODO naming` subnet
- _Infrastructure > Subnets_ Edit `default` subnet

```
Name: default
Network Address: 192.168.122.0
Network Prefix: 24
Network Mask: 255.255.255.0
Gateway Address: 192.168.122.1
Primary DNS server: 192.168.122.1
IPAM: DHCP
Start of IP range: 192.168.122.2
End of IP range: 192.168.122.254
MTU: 1500
Boot mode: DHCP
Proxies tab: Set all to your smart-proxy
Domains tab: local.test
```

Create a subnet, and assign DHCP proxy to it.

Try to create a host within the subnet, check the:
`cat /var/lib/dhcpd/dhcpd.leases`
