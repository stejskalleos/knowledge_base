# SeaBios - configuring PXE

## Packages

```bash
dnf install git gcc make binutils python3
dnf groupinstall "Development Tools"
```

## Download

```bash
git clone https://github.com/coreboot/seabios.git
cd seabios
git pull
```

## Configuring PXE

Make a backup

```bash
cp .config .config.BAK
```

Edit the `.config` file

```
CONFIG_PXE=y
CONFIG_PXE_IPV4=y
# CONFIG_PXE_IPV6 is not set
# CONFIG_PXE_HTTP is not set
```

Build

```bash
make
```

File is reverted after each build!
