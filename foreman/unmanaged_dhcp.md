# Foreman & Unmanaged DHCP with Foreman Bootdisk
Simple tutorial on how to set up Foreman (Satellite) with unmanaged DHCP.

## Installation
```
foreman-installer --foreman-unattended-url "http://192.168.190.16" \
  --foreman-proxy-dhcp false \
  --foreman-proxy-dhcp-managed false \
  --foreman-proxy-templates true \
  --foreman-proxy-registration-url "http://192.168.190.16:8000" \
  --foreman-proxy-template-url "http://192.168.190.16:8000" \
  --foreman-proxy-tftp false \
  --foreman-proxy-http true
```
_Note: If your DNS works fine (unlike mine), use FQDN instead of IP._

## Foreman Configuration
**Create OS**
```
hammer os create --name "CentOS_Stream" \
  --major 10 \
  --family "Redhat" \
  --password-hash "SHA512" \
  --architectures "x86_64" \
  --partition-tables "Kickstart default" \
  --media "CentOS Stream 9 mirror" \
  --location-title "Default Location" \
  --organization-title "Default Organization"
```

**Create domain**
```
hammer domain create --name "virtual.lan"
```

**Create subnet**
```
hammer subnet create --name "no_dhcp_subnet" \
  --network "192.168.190.0" \
  --prefix "24" \
  --mask "255.255.255.0" \
  --gateway "192.168.190.1" \
  --dns-primary "192.168.190.1" \
  --ipam "None" \
  --mtu "1500" \
  --boot-mode "DHCP" \
  --location-title "Default Location" \
  --organization-title "Default Organization"
```
Go into UI to the subnet detail and assign domains and smart proxies to it.

**Foreman Settings**
```
hammer setting set --name "update_ip_from_built_request" --value 1
hammer setting set --name "token_duration" --value 360
```
Notes:
* `update_ip_from_built_request` is required. Otherwise, you'll host ends up with an empty IP, which can cause problems in the future.
* `token_duration` must not be 0. Foreman uses the IP address to find the host if you disable build tokens. However, if the host doesn't have an IP, this will not work.

**Global parameters**
```
hammer global-parameter set --name "host_registration_insights" --value false --parameter-type boolean
hammer global-parameter set --name "kt_activation_keys" --value "default" --parameter-type string
hammer global-parameter set --name "subscription_manager_org" --value "Default Organization" --parameter-type string
subscription_manager
```

**Content**
```
hammer activation-key create  --name "default" \
   --organization-title "Default Organization" \
   --lifecycle-environment "Library" \
   --content-view "Default Organization View"
```

**Host groups**
```
hammer hostgroup create --name "bare-metal" \
  --location-title "Default Location" \
  --organization-title "Default Organization" \
  --domain "virtual.lan" \
  --subnet "no_dhcp_subnet" \
  --architecture  "x86_64" \
  --root-password "dog8code" \
  name=<string>\,value=<string>\,parameter_type=

hammer hostgroup create --name "stream10" \
  --parent-title "bare-metal" \
  --operatingsystem "CentOS_Stream 10" \
  --medium "CentOS Stream 9 mirror" \
```

## Configure DHCP
### With Libvirt
XML definition
```xml
<network>
  <name>foreman_default</name>
  <uuid>d8fbf022-dc8e-47c6-a632-cd5f94ac4a5b</uuid>
  <forward mode='nat'/>
  <bridge name='virbr90' stp='on' delay='0'/>
  <mac address='c8:3a:f7:78:48:7e'/>
  <domain name='virtual.lan' localOnly='no'/>
  <ip address='192.168.190.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.190.2' end='192.168.190.254'/>
    </dhcp>
  </ip>
</network>
```

See https://github.com/stejskalleos/knowledge_base/blob/main/tools/libvirt/new_network.md

### With ISC DHCP
TODO

## Host creation
### With full-host bootdisk iso
```
hammer host create --name "full-bootdisk" \
  --hostgroup-title "bare-metal/stream10" \
  --interface "mac=00:aa:aa:10:10:01" \
  --location-title "Default Location" \
  --organization-title "Default Organization"
```

Download iso to local:
```
hammer --verify-ssl false bootdisk host --host "full-bootdisk.virtual.lan" --file ~/isos/full-host.iso --full true
```

## Running VM with Libvirt
```
virt-install  --name=full-boot-disk \
              --vcpus=4 \
              --memory=4096 \
              --disk size=20 \
              --os-variant=centos-stream9 \
              --network "network=foreman_default,mac=00:aa:aa:10:10:01" \
              --connect qemu:///system \
              --boot cdrom,hd \
              --cdrom=full-host.iso
```
