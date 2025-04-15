# Foreman DEV environment with managed DHCP & DNS

Fedora setup, with `dhcpd` & `bind`.
The IP range is `192.168.66.2 192.168.66.254` for local domain `virtual.lan`. Feel free to adjust these values to your environment.

## Libvirt Network XML example

**isc.yml**
```xml
<network>
  <name>isc</name>
  <uuid>2764fd7d-c437-6666-b76d-484dfb0e933e</uuid>
  <forward dev='virbr66' mode='nat'>
    <interface dev='virbr66'/>
  </forward>
  <bridge name='virbr66' stp='on' delay='0'/>
  <mac address='52:54:00:a4:d3:1b'/>
  <domain name='virtual.lan' localOnly='yes'/>
  <dns>
    <host ip='192.168.66.1'>
      <hostname>gateway</hostname>
    </host>
  </dns>
  <ip address='192.168.66.1' netmask='255.255.255.0'>
  </ip>
</network>
```
Create a network for libvirt
```
virsh net-create ./isc.xml
virsh net-define ./isc.xml
virsh net-start isc
virsh net-autostart isc
```

## DHCP

### Installation & configuration

```
dnf install dhcp-server
```

Add configuration for your subnet

```
# /etc/dhcp/dhcpd.conf

See the dhcpd.conf
```

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
usermod -a -G dhcpd you
```

### Troubleshooting

```
tail -f /var/log/messages
journalctl -fxeu dhcpd.service

cat /var/lib/dhcpd/dhcpd.leases
```

## Smart Proxy

Add configuration files in `smart-proxy/config/settings.d/`

- `dhcp.yml`
- `dhcp_isc.yml`

See the sample files in `smart_proxy` directory.

## Foreman

Create a subnet, and assign DHCP proxy to it.
Try to create a host within the subnet, check the:

- `/var/lib/dhcpd/dhcpd.leases`
