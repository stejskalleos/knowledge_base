#!/bin/bash

virt-install \
--name=centos-stream9-vm \
--vcpus=4 \
--memory=4096 \
--disk size=20 \
--os-variant=centos-stream9 \
--network default \
--connect qemu:///system \
--location='/home/lstejska/Downloads/CentOS-Stream-9-latest-x86_64-dvd1.iso' \
--initrd-inject ./stream9.ks.cfg --extra-args "inst.ks=file:/stream9.ks.cfg"
