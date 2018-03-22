#!/usr/bin/bash

#Parameters
user=operator
password=redhat
email=operator@redhat.com
tenant=operators
externalNetwork=public
externalCidr='192.168.0.0/23'
externalGateway='192.168.0.1'
externalDns='192.168.0.6'
externalFipStart='192.168.1.70'
externalFipEnd='192.168.1.199'
tenantNetwork=private
tenantCidr='172.16.0.0/24'
keypairName=operator
keypairPubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBgQhKaDczdCAdJLiITel6IseKb7+eD+Uk1Lll19EWZiIFRu7zudHwGWajCcIXjg2vBJGbHk2tfn7JEPiiEaVDXztNGsDZXKimyUzXuuIw22A+ukHnmtr6LRO0ZS1RM0J2S6dWUB1qpgMCzIEKICrzdTnXLl7i5cHCfgF/4sIeAoekCx54xoAB50h1h+yMHa2mw+4IMiInldHFMg3DH4Dub+qgfYC4R8NWbMKIo2BSTNI2VGHtcTZzNsrSeD7AOvnz73B0ITnx/ObCTcDZ2ltL+ei7McmJR763dnaffI2AhgijKBs0suSnZ2I7kBmdjQDHWbfR7UMyy1qMuss7iqfNF"

unset OS_PROJECT_NAME
unset OS_TENANT_NAME

#Start as the admin user
source ~/overcloudrc

#Create the operators tenant and operator user defined above
openstack project create $tenant --description "Project intended for shared resources and testing by Operators" --enable
openstack user create $user --project $tenant --password $password --email $email --enable

#Grant the admin role to the operator admin
openstack role add admin --user $user --project $tenant

#create an rc file for the new operator user
cp overcloudrc ${user}rc
sed -i "s/\(export OS_USERNAME=\).*/\1${user}/" ${user}rc
sed -i "s/\(export OS_TENANT_NAME=\).*/\1${tenant}/" ${user}rc
sed -i "s/\(export OS_PROJECT_NAME=\).*/\1${tenant}/" ${user}rc
sed -i "s/\(export OS_PASSWORD=\).*/\1${password}/" ${user}rc

#Switch to the new operator
source ~/${user}rc

#Add ICMP and SSH incoming rules to the default security group in operators tenant
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

#Create a temp public key file
echo $keypairPubkey > /tmp/${keypairName}.pub
#Import the public key for the operator user
nova keypair-add --pub-key /tmp/${keypairName}.pub $keypairName

#Create a base flavor for use later
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 --public m1.tiny
openstack flavor create --id 2 --ram 1024 --disk 10 --vcpus 1 --public m1.small
openstack flavor create --id 3 --ram 2048 --disk 20 --vcpus 2 --public m1.medium
openstack flavor create --id 4 --ram 4096 --disk 40 --vcpus 4 --public m1.large
openstack flavor create --id 5 --ram 8192 --disk 80 --vcpus 8 --public m1.xlarge
openstack flavor create --id 6 --ram 12288 --disk 80 --vcpus 4 --public m1.cfme

#Create shared external network via flat provider type
neutron net-create $externalNetwork --provider:network_type flat --provider:physical_network datacentre --shared --router:external 

#Create external subnet
neutron subnet-create $externalNetwork $externalCidr --name ${externalNetwork}-sub --disable-dhcp --allocation-pool=start=$externalFipStart,end=$externalFipEnd --gateway=$externalGateway --dns-nameserver $externalDns

#Create a private tenant vxlan network
neutron net-create $tenantNetwork

#Create private tenant subnet
neutron subnet-create $tenantNetwork $tenantCidr --name ${tenantNetwork}-sub --dns-nameserver $externalDns

#Create provider networks
#Provisioning
neutron net-create provisioning --provider:network_type flat  --provider:physical_network prov 
neutron subnet-create provisioning 192.168.2.0/24 --name provisioning-sub --allocation-pool=start=192.168.2.60,end=192.168.2.99 --no-gateway
#Provider905
neutron net-create provider905 --provider:network_type vlan --provider:segmentation_id 905 --provider:physical_network datacentre 
neutron subnet-create provider905 192.168.105.0/24 --name provider905-sub --allocation-pool=start=192.168.105.20,end=192.168.105.199 --no-gateway
#Provider906
neutron net-create provider906 --provider:network_type vlan --provider:segmentation_id 906 --provider:physical_network datacentre 
neutron subnet-create provider906 192.168.106.0/24 --name provider906-sub --allocation-pool=start=192.168.106.20,end=192.168.106.199 --no-gateway

#Create a router
neutron router-create router-$externalNetwork
#Add an interface on the router for the tenant network
neutron router-interface-add router-$externalNetwork ${tenantNetwork}-sub
#Set the external gateway on the new router
neutron router-gateway-set router-$externalNetwork $externalNetwork

#Download the cirros test image
#curl -o /data/images/cirros.qcow2 http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
#qemu-img convert -f qcow2 -O raw /data/images/cirros.qcow2 /data/images/cirros035.img
#Upload the cirros test image to glance and share publicly
#glance image-create --name cirros035 --disk-format raw \
#  --container-format bare --visibility public --file /data/images/cirros035.img
glance image-create --name rhel74 --disk-format raw --min-disk 10 --min-ram 1024 \
  --container-format bare --visibility public --file /data/images/rhel-server-7.4-x86_64-kvm.img
glance image-create --name centos7 --disk-format raw --min-disk 10 --min-ram 1024 \
  --container-format bare --visibility public --file /data/images/CentOS-7-x86_64-GenericCloud.img
glance image-create --name rhel69 --disk-format raw --min-disk 10 --min-ram 1024 \
  --container-format bare --visibility public --file /data/images/rhel-guest-image-6.9-206.x86_64.img
glance image-create --name rhelatomic74 --disk-format raw --min-disk 10 --min-ram 1024 \
  --container-format bare --visibility public --file /data/images/rhel-atomic-cloud-7.4.1-5.x86_64.img
glance image-create --name spark160 --disk-format raw --min-disk 10 --min-ram 1024 \
  --container-format bare --visibility public --file /data/images/sahara-newton-spark-1.6.0-ubuntu.img
glance image-create --name cf45 --disk-format raw --min-disk 40 --min-ram 12288 \
  --container-format bare --visibility public --file /data/images/cfme-rhos-5.8.1.5-1.x86_64.img
