# Local RHEL 9 repository for provisioning

## HTTP configuration

Prepare directories

```
mkdir -p /var/www/html/boot/rhel9
```

Configure Apache `/etc/httpd/conf.d/boot.conf`

```
<VirtualHost *:80>
    KeepAlive On
    KeepAliveTimeout 600

    ServerName boot.local.lan
    DocumentRoot /var/www/html/boot

    <Directory /var/www/html/boot>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/boot_error.log
    CustomLog /var/log/httpd/boot.log combined
</VirtualHost>
```

Save & reload

```
httpd -t
service httpd reload
```

## RHEL 9 repo data

Download the _Red Hat Enterprise Linux 9.3 Binary DVD_ iso at https://access.redhat.com/downloads/content/rhel

Mount the iso

```
mount -o loop,ro -t iso9660 ~/Downloads/rhel-9.3-x86_64-dvd.iso /var/www/html/boot/rhel9

```

Check the repo is available at [boot.local.lan](http://boot.local.lan)

## Bootloader files

```
cp /var/www/html/boot/rhel9/EFI/BOOT/{BOOTX64.EFI,grubx64.efi} /var/www/html/boot
```

For shim files, needed for the Secure Boot, you need to spin up RHEL9 machine, install `shim` package and get the files from it.

```
dnf install shim
cp /rhel9_machine/boot/efi/EFI/redhat/{shimx64.efi,shimx64-redhat.efi} /your/localhost/var/www/html/boot/

chmod 755 /var/www/html/boot/*.{EFI,efi}
```

## Grub.cfg & Kickstart

**Grub.cfg** `/var/www/html/boot/grub.cfg`
See `grub.cfg`

**Kickstart** `/var/www/html/boot/ks_rhel9.cfg`

See `ks.cfg`
