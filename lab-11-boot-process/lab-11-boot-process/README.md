# Lab 11 — Controlling the Boot Process (CentOS/RHEL 8/9)

> **Environment:** Al‑Nafi cloud VM • **Init:** systemd • **Bootloader:** GRUB2 • **Access:** root/sudo

## Objectives
- Understand the **systemd** boot process and service management
- View and analyze **systemd services** and **targets**
- Modify boot parameters using the **GRUB2** bootloader
- Access and utilize **rescue mode** for troubleshooting boot failures
- Implement basic **boot‑process troubleshooting** techniques
- Configure system startup behavior through **systemd targets**

## Prerequisites
- Basic Linux command line
- File system navigation and text editing (`nano`, `vi`)
- Basic system administration concepts and `sudo` usage
- Completion of previous Linux labs

## Lab Environment (as provided)
- CentOS/RHEL 8 or 9 with **systemd**
- **GRUB2** pre‑installed
- **Root** access for system‑level operations
- All necessary tools/utilities pre‑configured

---

## Task 1: View systemd Services and Targets

### Subtask 1.1: Understanding systemd Basics
**Step 1:** Check systemd version  
```bash
systemctl --version
```
**Step 2:** View overall system status  
```bash
systemctl status
```
Shows uptime, number of running services, system load, and recent log entries.

### Subtask 1.2: Exploring systemd Services
**Step 3:** List all active services  
```bash
systemctl list-units --type=service --state=active
```
**Step 4:** List all services (active and inactive)  
```bash
systemctl list-units --type=service --all
```
**Step 5:** Check SSH service status  
```bash
systemctl status sshd
``)
**Step 6:** View detailed properties of a service  
```bash
systemctl show sshd
```

### Subtask 1.3: Working with systemd Targets
Targets are similar to traditional runlevels and define services for system states.
**Step 7:** List all available targets  
```bash
systemctl list-units --type=target
```
**Step 8:** Check the current default target  
```bash
systemctl get-default
```
**Step 9:** View dependencies for the current default target  
```bash
systemctl list-dependencies
```
**Step 10:** View dependencies required by the graphical target  
```bash
systemctl list-dependencies graphical.target
```

### Subtask 1.4: Managing Service States
**Step 11:** Start/stop chronyd  
```bash
# Check current status
systemctl status chronyd

# Stop the service
sudo systemctl stop chronyd

# Verify it's stopped
systemctl status chronyd

# Start the service again
sudo systemctl start chronyd

# Verify it's running
systemctl status chronyd
```
**Step 12:** Enable/disable automatic startup  
```bash
# Check if service is enabled
systemctl is-enabled chronyd

# Disable the service (won't start at boot)
sudo systemctl disable chronyd

# Enable the service (will start at boot)
sudo systemctl enable chronyd
```

---

## Task 2: Modify Boot Parameters with GRUB2

### Subtask 2.1: Understanding GRUB2 Configuration
**Step 13:** Examine the main GRUB2 defaults file  
```bash
sudo cat /etc/default/grub
```
**Step 14:** View the generated GRUB2 configuration (first 50 lines)  
```bash
sudo cat /boot/grub2/grub.cfg | head -50
```

### Subtask 2.2: Temporarily Modify Boot Parameters
**Step 15:** Reboot to access the GRUB2 menu  
```bash
sudo reboot
```
At the GRUB2 menu:  
1) Press any key to interrupt the boot.  
2) Highlight the default kernel entry.  
3) Press **e** to edit boot parameters.  
4) Find the line that starts with `linux` or `linux16`.  
5) Append `systemd.unit=multi-user.target` to the end.  
6) Press **Ctrl+X** to boot with these parameters.

**Step 16:** After boot, verify the current target  
```bash
systemctl get-default
systemctl list-units --type=target --state=active
```

### Subtask 2.3: Permanently Modify Boot Parameters
**Step 17:** Backup and edit GRUB defaults  
```bash
sudo cp /etc/default/grub /etc/default/grub.backup
sudo nano /etc/default/grub
```
**Step 18:** Ensure `GRUB_CMDLINE_LINUX` includes `quiet` (example):  
```text
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
```
**Step 19:** Regenerate GRUB2 configuration  
```bash
# For BIOS systems
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# For UEFI systems (CentOS path)
sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
```
**Step 20:** Set default systemd target permanently  
```bash
sudo systemctl set-default multi-user.target
systemctl get-default
```

---

## Task 3: Use Rescue Mode to Troubleshoot Boot Failures

### Subtask 3.1: Boot into Rescue Mode
**Step 21:** Reboot, at GRUB press **e**, append `systemd.unit=rescue.target` to the `linux` line, then **Ctrl+X**.

**Step 22:** Explore the rescue environment  
```bash
# Active targets
systemctl list-units --type=target --state=active

# Running services
systemctl list-units --type=service --state=active

# Mounted filesystems
df -h

# Current-boot logs
journalctl -b
```

### Subtask 3.2: Simulate and Fix a Boot Problem
**Step 23:** Create a deliberate fstab issue  
```bash
mount -o remount,rw /
cp /etc/fstab /etc/fstab.backup
echo "/dev/nonexistent /mnt/fake ext4 defaults 0 2" >> /etc/fstab
```
**Step 24:** Attempt normal boot  
```bash
systemctl default
```
(If it hangs/errors, reboot and reenter rescue mode.)

**Step 25:** Fix from rescue  
```bash
mount -o remount,rw /
sed -i '/nonexistent/d' /etc/fstab
cat /etc/fstab
# Or restore:
# cp /etc/fstab.backup /etc/fstab
```

### Subtask 3.3: Use Emergency Mode
**Step 26:** Reboot, at GRUB add `systemd.unit=emergency.target`, boot with **Ctrl+X**.  
**Step 27:** Explore emergency mode  
```bash
systemctl list-units --type=target --state=active
mount
mount -o remount,rw /
```

### Subtask 3.4: Password Recovery Scenario
**Step 28:** In rescue mode, reset credentials  
```bash
mount -o remount,rw /
passwd root
useradd -m testuser
passwd testuser
usermod -aG wheel testuser
```
**Step 29:** Return to normal operation  
```bash
systemctl set-default graphical.target   # if desired
systemctl reboot
```

---

## Troubleshooting Tips (quick)
- GRUB2 menu doesn’t appear → set `GRUB_TIMEOUT=5` and regenerate.
- Edits don’t take effect → regenerate the correct `grub.cfg`.
- Boot failure after `/etc/fstab` edit → rescue/emergency mode and revert.

## Verification
```bash
systemctl get-default
journalctl -b
systemctl status <service-name>
sudo cat /etc/default/grub
```

## Conclusion
You controlled the Linux boot process with **systemd** and **GRUB2**: managing services/targets, temporary and permanent kernel parameters, rescue/emergency modes, and recovery from configuration breakage. These are core RHCSA‑level skills for real‑world recovery, performance, and security.
