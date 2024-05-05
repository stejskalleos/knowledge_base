# Debugging

## Wireshark

```
wireshark -ki virbr90
```

## TFTP

`vim /usr/lib/systemd/system/tftp-server.service`

```
[Service]
ExecStart=/usr/sbin/in.tftpd -v -c -p -s /var/lib/tftpboot
```

Apply the changes

```
systemctl daemon-reload
systemctl restart tftp-server
```

Logs

```
journalctl -fxeu tftp-server
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

## Foreman

- SmartProxy log
- Foreman log
