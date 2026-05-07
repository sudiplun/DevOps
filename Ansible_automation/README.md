## Ansible notes

_Terminology_

- [x] Control Node

- [x] Managed Nodes
- [x] Inventory
      List of hosts you manage (can be a file or just localhost,)

```ini
; group level
[azure]
10.12.31.1 ansible_user=root ansible_ssh_private_key_file=~/.ssh/devops.pem

[databases]
10.12.31.2 ansible_user=root ansible_port=3306 ansible_ssh_private_key_file=~/.ssh/db_key.pem
```

- [x] playbook
      YAML file that says “run these roles/tasks on these hosts”
- [x] play
- [x] Task
      One single action in a playbook/role
- [x] Modules
      Built-in Ansible command (package, service, file, template, etc.)
- [x] Handlers

```yaml
# tasks/main.yml
- name: Copy zabbix_agentd.conf
  template:
  src: zabbix_agentd.conf.j2
  dest: /etc/zabbix/zabbix_agentd.conf
  notify: restart zabbix-agent # ← triggers handler only if file changes

# handlers/main.yml

- name: restart zabbix-agent
  service:
  name: zabbix-agent
  state: restarted
  Special task that runs only when notified (usually after a change, like service restart)
```

- [] Roles

---

_Terminology_ with the example

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
