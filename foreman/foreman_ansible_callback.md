# Foreman Ansible callback

Install Foreman collection
```bash
ansible-galaxy collection install theforeman.foreman --force
```

Configure Ansible
```cfg
# /etc/ansible/ansible.cf

[defaults]
callback_plugins = /home/YOUR-ACCOUNT/.ansible/collections/ansible_collections/theforeman/foreman/plugins/callback
callbacks_enabled = foreman

[callback_foreman]
url = http://localhost:3000
# This just haveto be set I think
ssl_cert = /etc/httpd/conf.d/_wildcard.local.lan-key.pem
ssl_key = /etc/httpd/conf.d/_wildcard.local.lan.pem
verify_certs = False
```

Create a "ping playbook"
```yaml
---
- name: Ping Playbook
  hosts: all
  become: yes
  become_user: root
  gather_facts: true
  tasks:
    - name: Show host's hostname
      debug:
        msg: "{{ ansible_ssh_host }}"
```

Run `ansible-playbook -i,your-machine -u root --key-file ~/.ssh/id_rsa ping_playbook.yml`
