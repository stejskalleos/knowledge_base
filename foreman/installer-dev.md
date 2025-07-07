# Installer - Development environment setup

**Packages**
```shell
dnf upgrade --refresh

dnf config-manager --set-enabled crb
dnf install https://yum.puppet.com/puppet-release-el-9.noarch.rpm -y

dnf groupinstall -y "Development Tools"

dnf install -y dnf-plugins-core libtool libyaml-devel \
  git gcc-c++ git ruby ruby-devel rubygem-bundler \
  openssl-devel libxml2-devel libxslt-devel zlib-devel \
  readline-devel systemd-devel tar libcurl-devel \
  puppet-agent tree
```

**Repositories**
```shell
mkdir -p /foreman
git clone --recursive git@github.com:theforeman/foreman-installer.git -b develop /foreman/installer
mkdir -p /foreman/installer/_build/modules

git clone git@github.com:theforeman/puppet-foreman.git /foreman/puppet-foreman
ln -s /foreman/puppet-foreman /foreman/installer/_build/modules/foreman
```

**Installer setup**
```shell
cd /foreman/installer
bundle
```

