#!/bin/bash

dnf install firewalld -y
systemctl enable firewalld.service
systemctl start firewalld.service

firewall-cmd --add-port="8000/tcp" --add-port="8443/tcp"
firewall-cmd --add-service=http --add-service=https
firewall-cmd --runtime-to-permanent

echo "$(hostname -I | awk '{print $1}') $(hostname -f)" > /etc/hosts
echo "127.0.0.1 localhost $(hostname -f)" >> /etc/hosts

source /etc/os-release 
dnf clean all
dnf install -y "https://yum.theforeman.org/releases/nightly/el$VERSION_ID/x86_64/foreman-release.rpm"
dnf install -y "https://yum.theforeman.org/katello/nightly/katello/el$VERSION_ID/x86_64/katello-repos-latest.rpm"
dnf upgrade -y
dnf install -y foremanctl

reboot now
