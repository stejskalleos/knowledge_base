# RPM

List all packages
```shell
rpm -qa
```

Info about the installed package
```shell
rpm -qi package_name
rpm -qpi package_file.rpm
```

Listing files
```shell
rpm -ql grub2-efi-x64
rpm -qpl package_file.rpm
```

Find source rpm of the file
```
rpm -qf /boot/efi/EFI/fedora/mmx64.efi
```
