## Installation

- nodejs
- nginx

_Command_

---

```bash
ansible-playbook -i inventory.ini playbook.yml # run with all server
ansible-playbook --limit azure  -i inventory.ini playbook.yml # run with azure group node
ansible-playbook -i inventory.ini playbook.yml --check  # check
```
