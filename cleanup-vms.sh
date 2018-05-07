#!/usr/bin/env bash

virsh destroy idm
virsh destroy repo
virsh destroy undercloud

virsh undefine idm
virsh undefine repo
virsh undefine undercloud

rm -rf /tmp/idm /tmp/repo /tmp/undercloud
rm -rf /var/lib/libvirt/images/*-os.qcow2

