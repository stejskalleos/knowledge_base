# Ansible Vault

Commands
```shell
vault create
vault edit
```

`ansible-playbook`
```shell
ansible-playbook --vault-password-file path-to-vault
```

Accessing variables
```yml
- name: Debug vault var
  ansible.builtin.debug:
    msg: "{{ authentik.pg.password }}"

- name: Debug vault var
  ansible.builtin.debug:
    msg: "{{ other_vault_val }}"
```

