# HTTPS & DEV ENV

## mkcert
[mkcert](https://github.com/FiloSottile/mkcert) is a simple tool for creating locally trusted development certificates. It requires no configuration.

### Installation
Download the latest `mkcert-vX.Y.Z-linux-amd64` from the [GitHub](https://github.com/FiloSottile/mkcert/releases).

```
mv ./mkcert /usr/bin/mkcert
chmod +x /usr/bin/mkcert
```

Reload the terminal.

### Certificates

```
cd /etc/httpd/conf.d
mkcert -install "*.local.lan"

# To see where the CA is:
echo $(mkcert -CAROOT)
```

## Foreman configuration

```yaml
# /path/to/foreman/config/settings.yaml

webpack_dev_server: true
webpack_dev_server_https: false
:domain: "local.lan"
:fqdn: "foreman.local.lan"
:hosts:
  - foreman.local.lan
  - localhost
```

## Smart Proxy

```yaml
# /path/to/smart/proxy/config/settings.yml
---
:trusted_hosts:
  - foreman.local.lan
  - localhost

:foreman_url: http://127.0.0.1:3000
:log_file: STDOUT
:http_port: 8000

:bind_host: ["*"]
:log_level: DEBUG
```

## Apache

```
dnf install httpd mod_ssl
```

Remove any `/etc/httpd/conf.d/*.conf` files that are not necessary.

See [httpd.conf](/data/httpd/httpd.conf)
See [foreman.conf](/data/httpd/foreman.conf)

```
# Check the config
apachectl configtest

# Start services
systemctl start httpd.service
systemctl enable httpd.service
```

## Firewall

```
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
```

## Poor man's DNS

`/etc/hosts`

```
127.0.0.1   localhost localhost.localdomain foreman.local.lan
::1         localhost localhost.localdomain foreman.local.lan

```

## Test it

```
curl -I http://foreman.local.lan

HTTP/1.1 302 Found
Date: Tue, 12 Mar 2024 13:16:27 GMT
Server: Apache/2.4.58 (Fedora Linux) OpenSSL/3.1.1
Location: https://foreman.local.lan/
```

## Adding CA to VM
and enable HTTPS communication from hosts to VM

Get the CA
```
cd $(mkcert -CAROOT)
cat rootCA.pem
```

Add it to VM
```
ssh root@your-vm
vim /etc/pki/ca-trust/source/anchors/foreman-ca.pem
# Copy the content of the CA

update-ca-trust extract
```

Test the connection:
```
curl --user admin:changeme "https://foreman.local.lan/api/hosts"
```

