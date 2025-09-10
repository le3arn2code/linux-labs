#!/usr/bin/env bash
# Lab 11 — Controlling the Boot Process (CentOS/RHEL 8/9)
# Follows the lab steps. Some steps require interactive GRUB edits (not scriptable).
# Run section-by-section on a VM (not a container).

set -euo pipefail

info() { printf "\n==> %s\n" "$*"; }
pause_note() { printf "\n[MANUAL STEP REQUIRED]\n%s\n" "$*"; }

# ---------- Task 1
info "Task 1: View systemd services and targets"
systemctl --version || true
systemctl status || true

systemctl list-units --type=service --state=active || true
systemctl list-units --type=service --all || true
systemctl status sshd || true
systemctl show sshd | head -50 || true

systemctl list-units --type=target || true
systemctl get-default || true
systemctl list-dependencies || true
systemctl list-dependencies graphical.target || true

info "Manage chronyd service"
systemctl status chronyd || true
sudo systemctl stop chronyd || true
systemctl status chronyd || true
sudo systemctl start chronyd || true
systemctl status chronyd || true
systemctl is-enabled chronyd || true
sudo systemctl disable chronyd || true
sudo systemctl enable chronyd || true

# ---------- Task 2
info "Task 2: GRUB2 configuration"
sudo cat /etc/default/grub || true
sudo sh -c 'head -50 /boot/grub2/grub.cfg 2>/dev/null || true'

pause_note "REBOOT to GRUB2 menu and TEMPORARILY add 'systemd.unit=multi-user.target' on the linux line, then boot with Ctrl+X (or F10).
After boot, run:
  systemctl get-default
  systemctl list-units --type=target --state=active"

info "Backup and edit GRUB defaults to include 'quiet' (manual edit may be required)"
sudo cp -f /etc/default/grub /etc/default/grub.backup
# Append 'quiet' if missing (non-destructive)
if ! grep -q 'GRUB_CMDLINE_LINUX=.*quiet' /etc/default/grub; then
  sudo sed -i 's/^GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="\1 quiet"/' /etc/default/grub
fi

info "Regenerate GRUB2 configuration (auto-select BIOS vs UEFI CentOS path)"
if [ -d /sys/firmware/efi ]; then
  sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
else
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

info "Set default systemd target to multi-user"
sudo systemctl set-default multi-user.target
systemctl get-default || true

# ---------- Task 3
pause_note "RESCUE MODE: reboot, edit kernel line, add 'systemd.unit=rescue.target', boot. Then use:
  systemctl list-units --type=target --state=active
  systemctl list-units --type=service --state=active
  df -h
  journalctl -b"

pause_note "Simulate a boot issue in rescue mode:
  mount -o remount,rw /
  cp /etc/fstab /etc/fstab.backup
  echo '/dev/nonexistent /mnt/fake ext4 defaults 0 2' >> /etc/fstab
  systemctl default
If it fails, return to rescue and fix:
  mount -o remount,rw /
  sed -i '/nonexistent/d' /etc/fstab
  cat /etc/fstab
  # or restore:
  # cp /etc/fstab.backup /etc/fstab"

pause_note "EMERGENCY MODE: reboot, add 'systemd.unit=emergency.target', boot. Explore:
  systemctl list-units --type=target --state=active
  mount
  mount -o remount,rw /"

pause_note "Password recovery (in rescue):
  mount -o remount,rw /
  passwd root
  useradd -m testuser && passwd testuser
  usermod -aG wheel testuser
Return to normal:
  systemctl set-default graphical.target   # optional
  systemctl reboot"

info "Lab 11 script complete."
