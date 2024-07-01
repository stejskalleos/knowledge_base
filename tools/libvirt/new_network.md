# Libvirt - Creating a new network
Network
```xml
<network>
  <name>foreman_dhcp</name>
  <uuid>d8fbf022-dc8e-47c6-47c9-cd5f94ac4a5b</uuid>
  <forward mode='nat'/>
  <bridge name='virbr80' stp='on' delay='0'/>
  <mac address='6A:1A:8A:dA:4A:dA'/>
  <domain name='dhcp.lan' localOnly='no'/>
  <dns>
    <host ip='192.168.180.1'>
      <hostname>foreman.local.lan</hostname>
    </host>
  </dns>
  <ip address='192.168.180.1' netmask='255.255.255.0'>
  </ip>
</network>
```

Commands
```bash
virsh net-create ./foreman_dhcp.xml
virsh net-define ./foreman_dhcp.xml
virsh net-start foreman_dhcp
virsh net-autostart foreman_dhcp
```

Applying changes
```bash
NET="foreman_dhcp";virsh net-edit $NET;virsh net-destroy $NET;virsh net-start $NET
```
