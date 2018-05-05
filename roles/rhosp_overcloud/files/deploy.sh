#!/usr/bin/env bash

cd ~
source ~/stackrc

openstack overcloud deploy --templates \
  -r /home/stack/templates/roles_data.yaml \
  -e /home/stack/templates/timezone.yaml \
  -e /home/stack/templates/cloudname.yaml \
  -e /home/stack/templates/ceilometer.yaml \
  -e /home/stack/templates/fernet.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/sahara.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-radosgw.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/cinder-backup.yaml \
  -e /home/stack/templates/storage-environment.yaml \
  -e /home/stack/templates/network-isolation.yaml \
  -e /home/stack/templates/network-environment.yaml \
  -e /home/stack/templates/compute.yaml \
  -e /home/stack/templates/nested-virt-post-deploy.yaml \
  --control-flavor control \
  --compute-flavor compute \
  --ceph-storage-flavor ceph-storage \
  --control-scale 1 \
  --compute-scale 3 \
  --ceph-storage-scale 0 \
  --ntp-server time.google.com \
  --timeout 60
