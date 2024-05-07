# Installing Vagrant on Fedora
## Installation
```bash
dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```
Install Vagrant from the `hashicorp` repository, **NOT FROM FEDORA**.
```bash
dnf install vagrant --repo hashicorp
```

## Vagrant Libvirt plugin
```bash
vagrant plugin install vagrant-libvirt
```
