systemctl stop glusterd
umount -l /gluster_bricks/data
umount -l /gluster_bricks/engine
umount -l /gluster_bricks/exports
umount -l /gluster_bricks/iso
umount -l /gluster_bricks/vmstore
for i in gluster_vg_sda gluster_vg_sdb gluster_vg_sdc gluster_vg_sdd; do vgremove $i; done
rm -rf /gluster_bricks
