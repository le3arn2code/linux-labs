# Lab 10: Managing Logical Volume Management (LVM)

This repo contains a **GitHub-ready** package for *Lab 10: Managing Logical Volume Management (LVM)*.

## Contents
- `README.md` — objectives, environment, and what you accomplished
- `commands.sh` — all commands in strict lab order (adapted to your actual device names)
- `troubleshooting.md` — real issues encountered & fixes
- `interview_qna.md` — 10 common interview questions **with answers** on LVM

## What this matches in your run
- Single extra NVMe disk: **/dev/nvme1n1** (40G)
- Partitioned into **/dev/nvme1n1p1**, **/dev/nvme1n1p2**, **/dev/nvme1n1p3**
- PVs on those 3 partitions; VGs: **vg_data** (p1+p2) and **vg_backup** (p3)
- LVs created and mounted under `/mnt/*`
- Snapshot step documented (and how to proceed when there isn't enough free PE)

---

## Objectives
- Understand PV/VG/LV/PE concepts
- Create PVs: `pvcreate`
- Create VGs: `vgcreate`
- Create/extend/shrink LVs: `lvcreate`, `lvextend`, `lvreduce`
- Format & mount: `mkfs.*`, `mount`, `/etc/fstab` (when needed)
- Snapshot basics
- Troubleshoot common LVM issues

## Outcomes you achieved
- Two volume groups across three PV partitions
- LVs:
  - `vg_data/lv_documents` (ext4, ~4G)
  - `vg_data/lv_projects` (ext4, ~100%FREE from vg_data)
  - `vg_backup/lv_backup` (ext4, 500M)
  - `vg_backup/lv_archive` (ext4, later resized to **200M**)
- Mounted at `/mnt/documents`, `/mnt/projects`, `/mnt/backup`, `/mnt/archive`
- Verified with `lsblk`, `lvs`, `vgs`, `pvs`, and `df -h`

> **Note:** Commands are provided exactly as used/required by the lab, adjusted for your actual device names (nvme-based) while keeping *no deviations* from the lab logic.
