# 10 LVM Interview Questions — With Answers

1) **What are PV, VG, LV, and PE in LVM?**  
**Answer:** *PV* (Physical Volume) is a disk or partition prepared for LVM. *VG* (Volume Group) pools one or more PVs. *LV* (Logical Volume) is carved from a VG and used like a disk partition. *PE* (Physical Extent) is the smallest allocatable unit within a VG (default 4MB).

2) **Why use LVM instead of classic partitions?**  
**Answer:** Flexibility (resize online in many cases), pooling storage across disks, easier growth, snapshots, and efficient space utilization.

3) **Can a single PV belong to multiple VGs?**  
**Answer:** No. One PV can be a member of exactly one VG. To have multiple VGs on one physical disk, create multiple **partitions** and use each as a PV in different VGs.

4) **How do you extend a logical volume and its filesystem?**  
**Answer:** `lvextend` to grow the LV, then grow the filesystem. For ext4: `lvextend -L +1G /dev/vg/lv && resize2fs /dev/vg/lv`. For XFS: `lvextend -L +1G /dev/vg/lv && xfs_growfs /mountpoint` (must be mounted).

5) **What must you do before shrinking an ext4 filesystem on LVM?**  
**Answer:** Unmount it, run `e2fsck -f`, shrink the filesystem with `resize2fs <newsize>`, then `lvreduce` to the same size, and re-mount. (XFS **cannot** shrink.)

6) **What is a snapshot LV and when would you use it?**  
**Answer:** A point-in-time copy-on-write LV useful for backups, testing, or consistent reads while the original changes. Requires free extents in the VG for the snapshot store.

7) **How do you move LVs from one PV to another in the same VG?**  
**Answer:** Use `pvmove /dev/oldPV /dev/newPV` then adjust with `vgreduce` if needed. This can be done online in many cases.

8) **What happens if the snapshot space fills up?**  
**Answer:** The snapshot becomes invalid and is typically dropped (failed state). Monitor and size snapshots appropriately or extend them (`lvextend`).

9) **How do you see the full LVM stack in one view?**  
**Answer:** `lsblk -f` plus `pvs`, `vgs`, `lvs` give a complete picture (filesystems, UUIDs, mountpoints, and LVM hierarchy).

10) **How do you persistently mount LVs?**  
**Answer:** Add entries to `/etc/fstab` using **UUID** or the device mapper path (`/dev/mapper/vg-lv`). Test with `mount -a` before rebooting.
