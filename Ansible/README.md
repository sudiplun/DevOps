## Ansible notes

_Terminology_

- [x] Control Node
- [x] Managed Nodes
- [x] Inventory
- [x] playbook
- [x] play
- [x] Tasks
- [x] Modules
- [] Handlers
- [] Roles

---

_Terminology_ will know the example

```yaml
# playbook
---
# play
- name: Ensure install packages # play name
  hosts: all # traget all hosts in Inventory
  become: true #  Become root (elevated privileges)
  # tasks
  tasks:
    - name: Ensure install nodejs
      # this is apt module
      ansible.builtin.apt:
        name: nodejs
        state: present

    - name: Ensure nginx is install
      # this is apt module
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx is running
      # this is also a systemctl service module
      service:
        name: nginx
        state: started
        enabled: yes

# Another play
- name: Update db servers
  hosts: databases
  remote_user: root

  tasks:
    - name: Ensure postgresql is at the latest version
      apt:
        name: postgresql
        state: latest

    - name: Ensure that postgresql is started
      ansible.builtin.service:
        name: postgresql
        state: started
```

---

Inventory file

```ini
; group level
[azure]
200.232.2.84 ansible_user=root ansible_ssh_private_key_file=~/.ssh/devops.pem

[databases]
32.50.107.133 ansible_user=root ansible_port=3306 ansible_ssh_private_key_file=~/.ssh/db_key.pem
```
