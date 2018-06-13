# hattrick guest images

This is the staging area for QCOW2 that are used as RHOSP guest images.  These images are used in:

`roles/rhosp_overcloud/templates/overcloudPostConfig.sh.j2`

### High level we use:

CentOS, RHEL 7, RHEL 6, CFME, Windows, Cirros, Spark, Atomic

These are referenced at https://docs.openstack.org/image-guide/obtain-images.html

### For CirrOS:

`wget https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img`

`qemu-img convert -f qcow2 -O qcow cirros-0.4.0-x86_64-disk.img cirros-0.4.0-x86_64-disk.qcow2`

### For Apache Spark:

http://sahara-files.mirantis.com/images/upstream/newton/

### For CFME and RHEL/RHEL Atomic (Access to Red Hat Customer Portal is required):
`access.redhat.com`

## Post download
Once you have downloaded the guest images to `hattrick/guest_images` fill out the `group_vars/all/vars` file and update the names with the latest versions.
