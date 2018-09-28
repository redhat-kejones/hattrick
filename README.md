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
- Kellen Gattis
- Russell Builta

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

## To Deploy a hattrick:

1. Follow the [instructions to create a bootable custom ISO](https://github.com/redhat-kejones/hattrick/tree/master/kvm-iso)
to install the RHEL+KVM utility server
2. Login to the new utility server
```
$ ssh root@192.168.0.3
```
3. Download the setup playbook that will clone this repo and copy the ssh key
> NOTE: you may need to mod the credentials in this file if you changed them
> in your custom ISO or provisioned the KVM host with different credentials
```
# wget https://raw.githubusercontent.com/redhat-kejones/hattrick/master/00-hattrick-setup.yml
```
4. Run the setup playbook
```
# ansible-playbook 00-hattrick-setup.yml
```
5. Set up your Ansible Vault file
> NOTE: you will be prompted to create an Ansible Vault password. You will need
> this password for the remaining automation
```
# ansible-vault encrypt /root/hattrick/group_vars/all/vault
# ansible-vault edit /root/hattrick/group_vars/all/vault
```
6. Move into the hattrick directory
```
# cd hattrick/
```
7. You need to either modify and use one of the existing inventory files or
create your own. They are located in /root/hattrick/inventories
```
# vi inventories/inventory-hattrick
```
8. You need to either modify and use one of the existing group_vars files or
create your own. They are located in /root/hattrick/group_vars
```
# vi group_vars/hattrick
```
9. Modify the group_vars/all/vars file
> NOTE: "destructive_filesystem" is destructive and will destroy any partitions
> that are created and defined in the roles folder that calls the filesytem
> module. Default is YES.
```
# vi group_vars/all/vars
```
10. Deploy your infrastructure. Currently only RHHI4C is complete
```
# screen -S ops
# ansible-playbook -i inventories/inventory-hattrick --ask-vault-pass deploy-rhhi4c.yaml
```
11. Modify the cf-vars file in order to deploy CloudForms
```
# vi cf-vars.yml
```
12. Deploy CloudForms on top
```
# ansible-playbook -i inventories/inventory-local --ask-vault-pass 08-rhcloudforms.yml
```
13. Modify the ocp-vars file in order to deploy OpenShift Container Platform
```
# vi ocp-vars.yml
```
14. Deploy OpenShift on top
```
# ansible-playbook -i inventories/inventory-local --ask-vault-pass 09-rhocp.yml
```
15. Modify the tower-vars file in order to deploy Ansible Tower
```
# vi tower-vars.yml
```
16. Deploy Ansible Tower on top
```
# ansible-playbook -i inventories/inventory-local --ask-vault-pass 10-ansible-tower.yml
```
