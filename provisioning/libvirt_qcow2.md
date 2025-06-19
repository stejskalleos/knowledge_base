# Libvirt/KVM image provisioning

**Preconditions**
```
usermod -a -G libvirt $USER
```

## Image download
```
wget https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2 -O ~/isos/stream10-generic-cloud.qcow2
```

**Permissions**
```
chmod ug+rw ~/isos/stream10-generic-cloud.qcow2
# chown "$USER":libvirt ~/isos/stream10-generic-cloud.qcow2
```

**Update the image**
```
virt-customize \
  -a stream10-generic-cloud.qcow2 \
  --copy-in /home/$USER/isos/sshd_config:/tmp \
  --run-command 'mv /tmp/sshd_config /etc/ssh/sshd_config' \
  --run-command 'chmod 600 /etc/ssh/sshd_config' \
  --run-command 'restorecon /etc/ssh/sshd_config
  --root-password password:changeme

# This should be done via one command above
# virt-customize -a stream10-generic-cloud.qcow2 --root-password password:changeme
```

## Next steps
* Add iso dir to Libvirt volumes path
* Create an image in Forema
