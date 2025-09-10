# interview_qna.md — 10 Boot & systemd Interview Questions **with Answers**

### 1) What is a systemd *target* and how does it relate to runlevels?
**Answer:** A target is a group of systemd units that define a system state (e.g., `multi-user.target`, `graphical.target`). They replace SysV runlevels: runlevel 3 ≈ `multi-user.target`; runlevel 5 ≈ `graphical.target`.

### 2) How do you change the default boot target?
**Answer:** Persistently: `sudo systemctl set-default <target>`. Verify with `systemctl get-default`. Temporarily at boot: append `systemd.unit=<target>` on the GRUB `linux` line.

### 3) Difference between `rescue.target` and `emergency.target`?
**Answer:** `rescue.target` is single-user mode with minimal services and a root shell. `emergency.target` is more minimal—no services—used for severe recovery (e.g., broken mounts).

### 4) How do you append a kernel parameter for one boot?
**Answer:** Interrupt GRUB, press **e**, edit the `linux` line, append the parameter (e.g., `systemd.unit=multi-user.target`), then boot with **Ctrl+X**/**F10**.

### 5) After editing `/etc/default/grub`, nothing changed. Why?
**Answer:** You must regenerate `grub.cfg` with `grub2-mkconfig -o <path>`, using the right path (BIOS `/boot/grub2/grub.cfg`; UEFI `/boot/efi/EFI/centos/grub.cfg`).

### 6) How do you diagnose a service failure during boot?
**Answer:** `systemctl status <unit>`; `journalctl -u <unit> -b`; check dependencies via `systemctl list-dependencies <unit>`; verify enablement with `systemctl is-enabled <unit>`.

### 7) How do you recover from a bad `/etc/fstab` that blocks boot?
**Answer:** Boot to `rescue.target` or `emergency.target`, remount `/` RW (`mount -o remount,rw /`), fix or restore `/etc/fstab`, then reboot.

### 8) Difference between `systemctl enable` and `systemctl start`?
**Answer:** `enable` configures boot-time activation; `start` starts it now. Use `systemctl enable --now <unit>` to do both.

### 9) How do you view only the current boot’s logs?
**Answer:** `journalctl -b` (current boot) or `journalctl -b -1` (previous boot). Add `-p warning` or `-xe` for filtering and detail.

### 10) How do you prevent users from editing GRUB entries at boot?
**Answer:** Set a GRUB password (e.g., `grub2-setpassword` on RHEL/CentOS) to configure a superuser and hashed password, then regenerate `grub.cfg`. Editing the menu requires authentication thereafter.
