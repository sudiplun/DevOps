## install required packages

`lvm2 dosfstools e2fsprogs`

## see visible device

`lsblk`

## initializa as LVM physical volume

```bash
pvcreate /dev/sda
```

## create a logical group

```bash
vgcreate my_vg /dev/sda
```

## create a logical volume

```bash
lvcreate -L 1G -n my_lv my_vg
```

## Format and mount it

```bash
mkfs -t ext4 /dev/my_vg/my_lv
mkdir /mnt/lvm-onrise
mount /dev/my_vg/my_lv /mnt/lvm-onrise
```

check
`df -h /mnt/lvm-onrise`

## Extend by 700MB

```bash
lvextend -L +700M /dev/my_vg/my_lv
```

## create snapshot

```bash
lvcreate -L 200M -S -n snap1 /dev/my_vg/my_lv


---
all i did this on qemu, by creating a 2G virtual disk for practice
`qemu-img create -f qcow2 lvm_disk.qcow2 2G` && mount with ` -drive file=lvm_disk.qcow2,format=qcow2`
```
