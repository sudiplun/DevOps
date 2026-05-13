# steps

official docs
https://galaxy.ansible.com/ui/repo/published/community/zabbix/
**INSTALLATION PACKAGES**

##### ansible

```bash
sudo apt install ansible
sudo dnf install ansible
sudo pacman -S ansible ansible-core
```

##### community.zabbix

`ansible-galaxy collection install community.zabbix`

### deployment of zabbix with playbook

```bash
ansible-playbook playbook.yml -i inventory.ini
ansible-playbook playbook.yml -i inventory.ini --ask-pass
```

you need python3 on manage node
