# Lab 4: File and Directory Permissions

This folder showcases my hands-on work for **Lab 4: File and Directory Permissions**.

## Objectives
- Understand file permission concepts (r, w, x for user, group, others).
- Modify file and directory permissions with `chmod` (numeric + symbolic).
- Change ownership with `chown` and `chgrp`.
- Implement Access Control Lists (ACLs) using `setfacl`.
- Verify permissions with `ls -l` and `getfacl`.
- Troubleshoot common permission-related issues.

## Prerequisites
- CentOS/RHEL-based Linux system with sudo/root access.
- Pre-installed ACL utilities (setfacl, getfacl).
- Basic familiarity with users, groups, and file operations.

## Tasks Performed (Summary)
1. **Create test files** (`textfile.txt`, `script.sh`, `testdir`).
2. **Use chmod numeric notation**: set `755`, `600`.
3. **Use chmod symbolic notation**: add/remove permissions for u/g/o.
4. **Directory permissions**: restrict and restore `x` bit to demonstrate directory traversal.
5. **Change ownership**: used `chown` to reassign files to `testuser:testgroup`.
6. **Recursive ownership**: `chown -R` on directories, `chgrp` to switch group only.
7. **ACL operations**: applied per-user and per-group ACLs, default ACLs on a directory, removed/modified ACLs.
8. **Verification script**: `permission_test.sh` created to automate checks.

## Troubleshooting Notes
- **Permission denied** → check `ls -l`, group membership (`groups`), ACL (`getfacl`).
- **ACL commands not found** → install with `sudo yum install acl -y` or `sudo apt install acl -y`.
- **ACLs not applying** → verify FS supports ACL: `mount | grep acl`, remount with `-o acl` if needed.

## Outcome
- Successfully practiced permission management with `chmod`, `chown`, and ACLs.
- Learned difference between standard Unix permissions vs. ACLs.
- Verified and troubleshooted permission errors.

## Next Steps
- Explore **special permission bits** (SUID, SGID, Sticky).
- Automate ACL and chmod configurations for project directories.
- Apply permissions to service-specific directories (e.g., web server roots).

---
**Lab check:**  
```bash
echo "Lab 4 - File and Directory Permissions completed successfully!"
```
