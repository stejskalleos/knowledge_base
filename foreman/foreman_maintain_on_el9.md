# Foreman-maintain from git on EL9

```shell
dnf install -y ruby-devel gcc make redhat-rpm-config git vim tree --disableplugin foreman-protector
```

Pull the repo
```shell
cd ~
git clone git@github.com:theforeman/foreman_maintain.git
cd foreman_maintain
bundle
```

Run

```shell
./bin/foreman-maintain
```
