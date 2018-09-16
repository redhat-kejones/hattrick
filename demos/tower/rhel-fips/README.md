Role Name
=========

An Ansible role based on https://access.redhat.com/solutions/137833

Requirements
------------

Role Variables
--------------

N/A

Dependencies
------------

To install dracut-fips and dracut-fips-aesni you need a valid RHEL subscription the following repositories:

For RHEL 7:

- rhel-7-server-rpms

For RHEL 6:

- rhel-7-server-rpms
- rhel-6-server-optional-rpms
- rhel-6-workstation-optional-rpms

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  become: yes
  roles:
    - ansible.fips
```

License
-------

BSD

Author Information
------------------

https://github.com/rhcreynold
