# Foreman Firewall
Enabling required ports
```shell
foreman-maintain service stop

firewall-cmd --permanent --add-port=8000/tcp \
  --add-port=443/tcp \
  --add-port=80/tcp \
  --add-port=9090/tcp \
  --add-port=5647/tcp \
  --add-port=8443/tcp \
  --add-port=67/udp \
  --add-port=68/udp \
  --add-port=8140/tcp \
  --add-port=8141/tcp

reboot now
```
