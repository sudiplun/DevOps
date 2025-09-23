*install required packages*

`lvm2 dosfstools e2fsprogs`

*see attach physical device*

`lsblk`

*initializa as LVM physical volume*

```bash
pvcreate /dev/sda
```

*create a logical group*

```bash
vgcreate DR1 /dev/sda
```

*create a logical volume*

```bash
lvcreate -L 10G -n DR1 root
```

*Format and mount it*

```bash
mkfs -t ext4 /dev/DR1/root
mkdir /mnt/lvm-onrise
mount /dev/DR1/root /mnt/lvm-onrise
```

check
`df -h /mnt/lvm-onrise`

*Extend by 700MB*

```bash
lvextend -L +40G /dev/DR1/root
```

*create snapshot*

```bash
lvcreate -L 20G S -n snap1 /dev/DR1/root
```

```bash
lvs
lvdisplay
lgs
lgdisplay
```

---

all i did this on qemu, by creating a 60G virtual disk for practice
`qemu-img create -f qcow2 lvm_disk.qcow2 60G` && mount with ` -drive file=lvm_disk.qcow2,format=qcow2`
