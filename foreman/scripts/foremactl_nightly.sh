#!/bin/bash
dnf clean all
dnf install -y https://yum.theforeman.org/releases/nightly/el9/x86_64/foreman-release.rpm
dnf install -y https://yum.theforeman.org/katello/nightly/katello/el9/x86_64/katello-repos-latest.rpm
dnf upgrade
dnf install foremanctl
