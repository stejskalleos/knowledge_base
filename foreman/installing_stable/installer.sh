#!/usr/bin/bash

export LANG_ALL=en_US.utf-8 LANG=en_US.utf-8

if ! [ $(id -u) = 0 ]; then
  bye 'This script must be run as a root'
fi

echo ''
echo 'Updating /etc/hosts'
echo "$(hostname -I | awk '{print $1}') $(hostname -f)" > /etc/hosts

foreman-installer --scenario katello \
    --foreman-initial-admin-username 'admin' \
    --foreman-initial-admin-password 'changeme'
