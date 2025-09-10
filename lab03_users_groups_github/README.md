# Lab 3: Managing Users and Groups

This folder showcases my hands-on work for **Lab 3: Managing Users and Groups**.

## Objectives
- Create users with `useradd` (default and custom options).
- Set and modify passwords with `passwd`.
- Update user details with `usermod` (shell, UID, home, lock/unlock).
- Create and manage groups with `groupadd`, `groupmod`, `gpasswd`.
- Add/remove users to/from groups (primary & secondary).
- Safely delete users and groups.
- Inspect `/etc/passwd`, `/etc/group`, `/etc/shadow` and apply security practices.

## Prerequisites
- Root/sudo privileges on a CentOS/RHEL-based system.
- User management utilities pre-installed (default on RHEL/CentOS).
- Terminal access.

## Tasks Performed (Summary)
1. **Inspect existing users** with `cat /etc/passwd | tail -5`, confirm identity (`whoami`).
2. **Create users**: `john`, `jane` (custom home), `mike` (shell), `sarah` (comment), `tom` (UID), `alice` (multiple options).
3. **Set passwords** for selected users with `passwd`.
4. **Modify user details**: change GECOS, home, shell, UID; lock/unlock accounts.
5. **Create groups**: `developers`, `testers`, `managers`, `admins` (GID), `sysops` (system group).
6. **Add users to groups** (primary & secondary; append mode with `-a -G`; `gpasswd` workflow).
7. **Verify memberships** with `groups`, `id`, `getent group`.
8. **Modify groups**: rename group and change GID.
9. **Remove users from groups** and **delete users** (`userdel`, `userdel -r`, `userdel -f`), then **delete groups**.
10. **Security**: password aging and expiration via `chage`; safe cleanup; verify via `passwd -S`, `chage -l`.

## Troubleshooting Notes
- **user already exists** → `getent passwd username`; use `usermod` instead.
- **permission denied** → use `sudo` or `sudo su -`.
- **group deletion fails** (primary group of a user) → change user’s primary group first `usermod -g newgroup username`, then `groupdel oldgroup`.
- **home not created** → create and set ownership manually; copy from `/etc/skel`.
- **Login issues after shell change** → ensure target shell exists and is listed in `/etc/shells`.

## Outcome
- Users and groups created, modified, and deleted safely.
- Group memberships verified.
- Security practices (locking accounts, password aging) applied.

## Next Steps
- Explore **Lab 4: File and Directory Permissions** (chmod/chown/ACLs).
- Integrate with sudoers management and PAM configuration.
- Automate via Ansible user/group modules.

---
**Lab check:**  
```bash
echo "Lab 3 - Managing Users and Groups completed successfully!"
```
