# hattrick
Project Hat Trick - Open Architectures for Full Stack!

The playbooks in this project can be used as a baseline for deploying a vast majority of Red Hat's product portfolio in a defined manner. The playbooks were originally built out to deploy on a set of field kits used by Red Hat North American Public Sector Solutions Architects.

The playbooks are built to be launched by running the main deploy-rhhi4c.yml playbook. However, they are also setup in a way to be utilized in a standalone fashion.

Currently the provisioning of resources happens on a main RHEL+KVM host for deployment. Once Red Hat OpenStack is up and running, the remaining resources are provisioned on top of OpenStack. The provisioning mechanisms could be replaced with another infrastructure provider like RHV, VMware or Public Clouds.

All variables are in either group_vars/all/vars.yml or specified with the roles group_vars file.

We've attempted to make this setup very flexible. However, if you believe there is a better way, please contribute.

Contributors:
- Jason Ritenour
- Chris Reynolds
- Jared Hocutt
- Chris Alliey
- Laurent Domb
- Kevin Jones
- Jamie Duncan
- Steven Carter

Initial Architecture

The Ansiblized switch and router configs have been left out of this repo. The switch we were using for this project is not fully managed. With that in mind there is a switch config file in the files directory so that you may at least see our switch configuration.

Router: 192.168.0.1
Switch: 192.168.0.2

Networks:
- 192.168.0.0/23 External/Public network (VLAN 1)
  (192.168.0.0/24 subnet used for infrastructure and 192.168.1.0/24 used for OpenStack external network)
- 192.168.2.0/24 Provisioning (VLAN 2)
- 192.168...

RHEL+KVM: 192.168.0.3
VMs:
- Red Hat Identity Manager (IDM and provides DNS): 192.168.0.4
- Red Hat Repo Server: 192.168.0.8
- Red Hat OpenStack Platform Director: 192.168.0.5

To Deploy a hattrick:
Modify/Create:
- inventories/inventory-hattrick - make sure your hosts are correct
- group_vars/hattrick - change the domain from int.hattrick.lab to what you are using
- group_vars/all/vault.yml - create this from the sample file in the directory
- group_vars/all/vars - modify if needed.  NOTE: "destructive_filesystem" is destructive and will destroy any partitions that are created and defined in the roles folder that calls the filesytem module.  Default us YES.

Deploy command:
`ansible-playbook -i inventories/inventory-hattrick --ask-vault-pass deploy-rhhi4c.yaml`

Note: this will fail at the deploying of CFME as the hosts are unknown since they get a DHCP IP, you will need to run 08-rhcloudforms.yml after updating the cf-vars.yml file.  Then run:
`ansible-playbook --ask-vault-pass 08-rhcloudforms.yml`

For Tower:
Update tower-vars.yml then run:
`ansible-playbook --ask-vault-pass 11-ansible-tower.yml`

For OCP:
Update ocp-vars.yml then run:
`ansible-playbook --ask-vault-pass rhocp.yml`
