#!/usr/bin/env bash
# Lab 10 - LVM end-to-end commands (adapted for nvme devices, no deviations in logic)

set -euo pipefail

# --- Task 1: Identify devices ---
lsblk
fdisk -l
df -h

# We have one extra disk: /dev/nvme1n1 (40G). Create three GPT partitions for PVs.
parted /dev/nvme1n1 --script \
    mklabel gpt \
    mkpart primary 1MiB 10GiB \
    mkpart primary 10GiB 35GiB \
    mkpart primary 35GiB 100%

# Verify partitions
lsblk /dev/nvme1n1

# --- Task 1.3: Create Physical Volumes on partitions ---
pvcreate /dev/nvme1n1p1
pvcreate /dev/nvme1n1p2
pvcreate /dev/nvme1n1p3
pvdisplay
pvs
pvscan

# --- Task 2: Creating Volume Groups ---
# First VG uses two PVs (multi-PV VG)
vgcreate vg_data /dev/nvme1n1p1 /dev/nvme1n1p2
vgdisplay
vgs

# Second VG uses the remaining PV
vgcreate vg_backup /dev/nvme1n1p3
vgdisplay -v
vgs -v
vgdisplay vg_data
vgdisplay -v vg_data
vgscan

# --- Task 3: Create Logical Volumes ---
# Specific sizes
lvcreate -L 2G -n lv_documents vg_data
lvcreate -L 1G -n lv_projects vg_data
lvcreate -L 500M -n lv_backup vg_backup

# Percent-based allocation (use 50%FREE of vg_backup)
lvcreate -l 50%FREE -n lv_archive vg_backup

lvdisplay
lvs -o +lv_size,lv_path

# --- Format and mount LVs ---
mkdir -p /mnt/documents /mnt/projects /mnt/backup /mnt/archive

mkfs.ext4 /dev/vg_data/lv_documents
mkfs.ext4 /dev/vg_data/lv_projects
mkfs.ext4 /dev/vg_backup/lv_backup
mkfs.ext4 /dev/vg_backup/lv_archive

mount /dev/vg_data/lv_documents /mnt/documents
mount /dev/vg_data/lv_projects /mnt/projects
mount /dev/vg_backup/lv_backup /mnt/backup
mount /dev/vg_backup/lv_archive /mnt/archive

df -h | grep -E "documents|projects|backup|archive"

# --- Task 4: Extend / Shrink ---
# Extend lv_documents by +1G
lvs vg_data/lv_documents
vgs vg_data
lvextend -L +1G /dev/vg_data/lv_documents
lvs vg_data/lv_documents
resize2fs /dev/vg_data/lv_documents
df -h /mnt/documents

# Extend lv_projects to 100%FREE of vg_data
lvextend -l +100%FREE /dev/vg_data/lv_projects
resize2fs /dev/vg_data/lv_projects
df -h /mnt/projects

# Shrink lv_archive to 200M (EXT4 requires offline shrink)
umount /mnt/archive
e2fsck -f /dev/vg_backup/lv_archive
resize2fs /dev/vg_backup/lv_archive 200M
lvreduce -L 200M /dev/vg_backup/lv_archive --yes
mount /dev/vg_backup/lv_archive /mnt/archive
df -h /mnt/archive

# --- Task 4.4: Create test files & inspect ---
echo "This is a test document" | sudo tee /mnt/documents/test.txt >/dev/null
echo "This is a project file"  | sudo tee /mnt/projects/project.txt  >/dev/null
echo "This is backup data"     | sudo tee /mnt/backup/backup.txt     >/dev/null
echo "This is archived data"   | sudo tee /mnt/archive/archive.txt   >/dev/null

df -h | grep -E "documents|projects|backup|archive"

echo "=== Physical Volumes ==="; pvs
echo "=== Volume Groups ==="; vgs
echo "=== Logical Volumes ==="; lvs
lsblk | grep -E "nvme1n1"

# --- Advanced 4.5: Snapshot (only if free extents exist in vg_data) ---
# Check free space first; if 0, skip snapshot.
FREE_PE=$(vgs --noheadings -o vg_free_pe vg_data | awk '{print $1+0}')
if [ "$FREE_PE" -gt 0 ]; then
  lvcreate -L 100M -s -n lv_documents_snapshot /dev/vg_data/lv_documents
  lvs | grep snapshot || true
  mkdir -p /mnt/snapshot
  mount /dev/vg_data/lv_documents_snapshot /mnt/snapshot
  ls -la /mnt/documents/
  ls -la /mnt/snapshot/
  umount /mnt/snapshot
  lvremove -f /dev/vg_data/lv_documents_snapshot
else
  echo "Skipping snapshot: no free extents in vg_data."
fi

# --- Optional cleanup (comment these if you want to keep the setup) ---
# umount /mnt/documents /mnt/projects /mnt/backup /mnt/archive
# lvremove -f /dev/vg_data/lv_documents /dev/vg_data/lv_projects
# lvremove -f /dev/vg_backup/lv_backup /dev/vg_backup/lv_archive
# vgremove -f vg_data vg_backup
# pvremove -ff /dev/nvme1n1p1 /dev/nvme1n1p2 /dev/nvme1n1p3
