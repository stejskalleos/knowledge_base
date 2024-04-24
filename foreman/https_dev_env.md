# HTTPS & DEV ENV

## mkcert

`mkcert` is a simple tool for making locally-trusted development certificates. It requires no configuration.
https://github.com/FiloSottile/mkcert

### Installation
Download the latest `mkcert-vX.Y.Z-linux-amd64` from the [GitHub](https://github.com/FiloSottile/mkcert/releases).

```
mv ./mkcert /usr/bin/mkcert
chmod +x /usr/bin/mkcert
```

Reload the terminal.

### Certificates
Generate and install the local CA in the system trust store.

```
mkcert -install

# To see where the CA is:
echo $(mkcert -CAROOT)
```

Generate certificate and key

```
mkcert "*.local.lan"
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

## TODO

- SSL settings for Proxy authentication
- Proxy SSL config
- Test it with VM

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
systemctl restart httpd
```

## Poor man's DNS

`/etc/hosts`

```
127.0.0.1   localhost localhost.localdomain foreman.local.lan
::1         localhost localhost.localdomain foreman.local.lan

```

## Firewall

```
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
```

## Test it

```
curl -I http://foreman.local.lan

HTTP/1.1 302 Found
Date: Tue, 12 Mar 2024 13:16:27 GMT
Server: Apache/2.4.58 (Fedora Linux) OpenSSL/3.1.1
Location: https://foreman.local.lan/
```
