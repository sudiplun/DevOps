# VMware
### to enable network for vmware
sudo systemctl start vmware-networks.service
 
#create image of qemu-img
### NOTES: this read the *.iso from current directory
qemu-img create -f qcow2 debain-12.img 20G

#### with port bind
qemu-system-x86_64 -enable-kvm -cdrom debain_12.10.iso -drive file=debain-12.img -m 2G -nic user,hostfwd=tcp::60022-:22

# run virtual disk with qemu
qemu-system-x86_64 -enable-kvm -cdrom sl.iso -boot menu=on -drive file=sl.img -m 2G

# see permission in digits
`stat -c "%a" file/directory`

# ufw (firewall command) 
sudo ufw enable # after get install the package 
sudo ufw status # check the active or not 

`Firewall is active and enabled on system startup`

sudo ufw app list # Avialable application list 
sudo ufw allow "openssh" # add to 
sudo ufw delete allow openssh


# du and df command 
df # this one for  disk available 
du # used by file/directoruo

# inodes
this cames into while creating hard and soft link of file.

# nginx 
- proxy server 
- reverse server
- vhost

# docker
external: true

network type 
- bridge 
- host 

# anisble 
- update remote server via anisble 
- little talk about khalti

# kubernetes 
- load balancing
- self healing 
- up and down scaling

### master vm
- it has api-scheme
- etcd
- schedule

*master file*   has apply--> 
controller manager 

