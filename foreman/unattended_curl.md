# Curl for unattended/provision endpoint

**By MAC**
```shell
curl -H "X-RHN-Provisioning-MAC-0: eth0 00:aa:aa:66:66:01" https://foreman.local.lan/unattended/provision
```

**By IP**
```shell
curl -H "REMOTE_ADDR: 192.168.190.23" https://foreman.local.lan/unattended/provision
curl -H "REMOTE_ADDR: 2620:52:0:9f:f816:3eff:fec4:1ba" https://foreman.local.lan/unattended/provision
```
