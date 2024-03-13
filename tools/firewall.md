# Firewall

```
systemctl stop firewalld
systemctl start firewalld

systemctl disable firewalld
systemctl enable firewalld
```

Reload firewall and keep state information

```
firewall-cmd --reload
```

Get info about the `FedoraWorkstation` zone

```
firewall-cmd --list-all
```
