# Apt-Cacher-NG

https://wiki.debian.org/AptCacherNg
Cache repositories and save time in provisioning.
Works with dnf as well!

## Installation
```shell
sudo dnf install apt-cacher-ng
sudo systemctl enable --now apt-cacher-ng

sudo firewall-cmd --add-port=3142/tcp --permanent
sudo firewall-cmd --reload
```

## Configuration
```shell
# /etc/apt-cacher-ng/acng.conf

# Helper to allow more file types (vital for DNF/YUM metadata)
PfilePatternEx: \.zst$|\.solv$|\.sig$|\.asc$|\.rpm$|\.drpm$|\.img$|\.iso$|\.treeinfo$|vmlinuz|initrd

# Don't block unknown repositories (useful if you use many varying mirrors)
PassThroughPattern: .*
```

```shell
sudo systemctl restart apt-cacher-ng
```

## Foreman configuration

Set parameters on domain, hostgroup or os:
```
http-proxy      192.168.66.1
http-proxy-port 3142
```

## Debuging

http://localhost:3142/acng-report.html

```
tail -f /var/log/apt-cacher-ng/apt-cacher.lo
# (you have to enable the tracing first in UI panel)
```
