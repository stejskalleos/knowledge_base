#!/usr/bin/bash

export LANG_ALL=en_US.utf-8 LANG=en_US.utf-8

if ! [ $(id -u) = 0 ]; then
  bye 'This script must be run as a root'
fi

echo '####'
echo 'Installing Foreman'

echo ''
echo 'Repos'
dnf clean all

rm -rf /etc/yum.repos.d/epel*

dnf install https://yum.theforeman.org/releases/3.9/el8/x86_64/foreman-release.rpm -y
dnf install https://yum.theforeman.org/katello/4.11/katello/el8/x86_64/katello-repos-latest.rpm -y
dnf install https://yum.puppet.com/puppet7-release-el-8.noarch.rpm -y
dnf config-manager --set-enabled powertools -y
dnf module enable katello:el8 -y
dnf update -y
dnf install foreman-installer-katello -y

reboot now