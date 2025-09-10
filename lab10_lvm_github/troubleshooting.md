# Troubleshooting (from our run)

## 1) `pvcreate` not found
**Symptom:** `-bash: pvcreate: command not found`  
**Fix:** install LVM tooling
```bash
sudo yum install -y lvm2 device-mapper
# or on DNF-based:
sudo dnf install -y lvm2 device-mapper
```

## 2) Only one extra disk available for a lab asking for multiple
**Approach:** Create **multiple GPT partitions** on the single disk and use each partition as a **PV**.  
We used `/dev/nvme1n1p1`, `/dev/nvme1n1p2`, `/dev/nvme1n1p3` → made two VGs as required by the lab.

## 3) Permission denied when writing files in mounted LVs
Redirection (`>`) happens **before** `sudo`. Use `sudo tee`:
```bash
echo "text" | sudo tee /mnt/documents/file.txt >/dev/null
```
Or adjust ownership if needed:
```bash
sudo chown -R $USER:$USER /mnt/documents
```

## 4) Snapshot creation failed (insufficient free space)
**Symptom:**
```
lvcreate -L 100M -s -n lv_documents_snapshot /dev/vg_data/lv_documents
  Volume group "vg_data" has insufficient free space ...
```
**Fixes:**
- Free space in the VG (extend VG with another PV or reduce LV size)
- Create a smaller snapshot (`-L 64M` for example)
- Remove unnecessary snapshots/LVs first

## 5) Mount errors on LVs
- Ensure FS created: `file -s /dev/vg_name/lv_name` or `dumpe2fs -h ...`
- Create mount point: `sudo mkdir -p /mnt/<dir>`
- Check if already mounted: `mount | grep <lv_name>`

## 6) Shrinking EXT4
- Must unmount, then `e2fsck -f`, then `resize2fs`, then `lvreduce`.
- Re-mount and verify with `df -h`.

## 7) General inspection
```bash
pvs; vgs; lvs
lsblk -f
df -hT
```

