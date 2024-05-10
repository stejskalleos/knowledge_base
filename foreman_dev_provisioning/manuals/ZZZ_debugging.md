# Debugging

## Wireshark

```bash
sudo dnf install wireshark
sudo wireshark -ki virbr90
```

## TFTP

`vim /usr/lib/systemd/system/tftp-server.service`

```
[Service]
ExecStart=/usr/sbin/in.tftpd -v ...
```

Apply the changes

```
systemctl daemon-reload
systemctl restart tftp-server
```

Logs

```
journalctl -fxeu tftp
```

## DHCP

`vim /etc/systemd/system/dhcpd.service`

```bash
ExecStart=/usr/sbin/dhcpd -d ...
```

```
systemctl daemon-reload
systemctl restart dhcpd
```

Logs

```
journalctl -fxeu dhcpd
```

Config validator

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

## Foreman

- SmartProxy log
- Foreman log
