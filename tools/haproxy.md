# HA proxy on RHEL 9
### Setup
Packages
```shell
dnf install -y haproxy policycoreutils-python-utils vim -y
```

SElinux
```shell
semanage boolean --modify --on haproxy_connect_any
```

Backup config
```shell
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.BAK
```

## Configuration
```shell
global
  
  chroot      /var/lib/haproxy
  pidfile     /var/run/haproxy.pid
  maxconn     4000
  user        haproxy
  group       haproxy
  daemon

defaults
	retries             	3
	timeout http-request	10s
	timeout queue       	1m
	timeout connect     	10s
	timeout client      	1m
	timeout server      	1m
	timeout http-keep-alive 10s
	timeout check       	10s
	maxconn             	3000

#https
frontend https
   bind *:443
   mode tcp
   option              	tcplog
   default_backend f-proxy-https

backend f-proxy-https
   option tcp-check
   balance source
   server f-proxy-https-1 10.0.167.57:443 check

#http foreman
frontend http
   bind *:80
   mode tcp
   option              	tcplog
   default_backend f-proxy-http

backend f-proxy-http
   option tcp-check
   balance roundrobin
   server f-proxy-http-1 10.0.167.57:80 check

# capsule_https
frontend https_capsule
   bind *:9090
   mode tcp
   option               tcplog
   default_backend f-proxy-https-capsule

backend f-proxy-https-capsule
   option tcp-check
   balance source
   server f-proxy-https-capsule-1 6.6.6.23:9090 check

#amqp
frontend amqp
   bind *:5647
   mode tcp
   option              	tcplog
   default_backend f-proxy-amqp

backend f-proxy-amqp
   option tcp-check
   balance roundrobin
   server f-proxy-amqp-1 6.6.6.23:5647 check

#anaconda
frontend anaconda
   bind *:8000
   mode tcp
   option              	tcplog
   default_backend f-proxy-anaconda

backend f-proxy-anaconda
   option tcp-check
   balance roundrobin
   server f-proxy-anaconda-1 6.6.6.23:8000 check

#puppet
frontend puppet
   bind *:8140
   mode tcp
   option              	tcplog
   default_backend f-proxy-puppet

backend f-proxy-puppet
   option tcp-check
   balance roundrobin
   server f-proxy-puppet-1 6.6.6.23:8140 check

#puppet-ca
frontend puppet-ca
   bind *:8141
   mode tcp
   option              	tcplog
   default_backend f-proxy-puppet-ca

backend f-proxy-puppet-ca
   option tcp-check
   balance roundrobin
   server f-proxy-puppet-ca-1 6.6.6.23:8140 check

#rhsm
frontend rhsm
   bind *:8443
   mode tcp
   option              	tcplog
   default_backend f-proxy-rhsm

backend f-proxy-rhsm
   option tcp-check
   balance roundrobin
   server f-proxy-rhsm-1 6.6.6.23:8443 check

#scap
frontend scap
   bind *:9090
   mode tcp
   option              	tcplog
   default_backend f-proxy-scap

backend f-proxy-scap
   option tcp-check
   balance roundrobin
   server f-proxy-scap-1 6.6.6.23:9090 check
```

Enable and restart
```shell
systemctl enable haproxy
systemctl restart haproxy
```

Firewall
```
firewall-cmd --permanent --add-port=8000/tcp \
  --add-port=443/tcp \
  --add-port=80/tcp \
  --add-port=9090/tcp \
  --add-port=8000/tcp \
  --add-port=5647/tcp \
  --add-port=8443/tcp \
  --add-port=67/udp \
  --add-port=68/udp \
  --add-port=8140/tcp \
  --add-port=8141/tcp

reboot now
```
