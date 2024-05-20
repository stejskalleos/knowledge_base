# Initial Setup

TODO:
Build templates

```
sudo dnf install dnf-plugins-core
[…]# sudo dnf config-manager --add-repo http://www.kraxel.org/repos/firmware.repo
[…]# sudo dnf install edk2.git-ovmf-x64
```

## Firewall

??? Add virbr90 to trusted

```bash
firewall-cmd --permanent --add-port=67/udp;firewall-cmd --permanent --add-port=68/udp;firewall-cmd --permanent --add-port=69/udp;firewall-cmd --permanent --add-port=8080/tcp;firewall-cmd --reload
```

journalctl -f
