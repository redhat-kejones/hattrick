Name
=========


A place for demo stuff to go

Note
-------
To use the `os_server:` module you need to install python-pip from epel and the run:

`pip install shade`

Also you will have to put `vault_osp_user` and `vault_osp_pwd` in as extra vars since tower doesn't follow group_vars to the vault file

for `launch_workflow_from_cfme.yml` use the following steps:

- CloudForms launches a Job Template (called 'Launch Workflow Job Template')
- Ansible playbook launches the Workflow Job Template with a POST on Tower
- Tower executes the Workflow Job Template, which in turns executes Job Templates


License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
