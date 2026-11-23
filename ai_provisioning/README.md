# Foreman Provisioning - Local Development Setup

Foreman + Smart Proxy setup with following provisioning methods:

* Minikube with Kubevirt ([minikube.md](./minikube.md))
* Libvirt

## PRE 

.env file

```shell
cp .env.EXAMPLE .env
```
## Setup

### Operating Systems

```
hammer os create --name "CentOS_Stream" \
  --major 10 \
  --family "Redhat" \
  --password-hash "SHA512" \
  --architectures "x86_64" \
  --partition-tables "Kickstart default" \
  --media "CentOS Stream 9 mirror" \
  --location-title "Default Location" \
  --organization-title "Default Organization"
```

### Domains

```shell
hammer domain create --name "virtual.lan"
hammer domain create --name "minikube.lan"
```

### Provisioning Templates

Associate the OS with the templates needed for UEFI PXE boot (`PXEGrub2`), user data (needed for cloud-init, e.g. the Minikube/KubeVirt image) and set them as the OS defaults. BIOS PXE (`PXELinux`) and `iPXE` templates aren't needed here.

**TODO**: Kickstart default template and the bootloader and the medium (should be already assigned)

```shell
be bin/hammer os add-provisioning-template --title "CentOS_Stream 10" \
  --provisioning-templates "Kickstart default PXEGrub2,Kickstart default user data"
OS_ID=$(be bin/hammer --csv os list --search 'title = "CentOS_Stream 10"' --fields id | tail -1)
PXEGRUB2_ID=$(be bin/hammer --csv template list --search 'name = "Kickstart default PXEGrub2"' --fields id | tail -1)
USERDATA_ID=$(be bin/hammer --csv template list --search 'name = "Kickstart default user data"' --fields id | tail -1)

be bin/hammer os set-default-template --id "$OS_ID" --provisioning-template-id "$PXEGRUB2_ID"
be bin/hammer os set-default-template --id "$OS_ID" --provisioning-template-id "$USERDATA_ID"
```

HTTPBoot provisioning reuses the same `PXEGrub2` template kind — Foreman's HTTPBoot smart-proxy feature serves it over HTTP instead of TFTP, so no separate template or association is needed for it.
