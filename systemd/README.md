# Podman Quadlet

* https://docs.podman.io/en/latest/markdown/podman-quadlet.1.html
* https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

## Commands

Analyze unit files
```shell
# rootless
systemd-analyze --user --generators=true verify example.container

# Root containers
systemd-analyze --generators=true verify example.container
```
```
```

