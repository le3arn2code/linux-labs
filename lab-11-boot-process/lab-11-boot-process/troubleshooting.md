# troubleshooting.md — Errors Observed & Fixes (Boot Process Lab)

Below are the issues encountered/expected in this environment and how we resolved them.

---

## 1) GRUB2 menu doesn't appear
**Symptom:** System boots without showing the GRUB menu (can't press **e**).  
**Cause:** `GRUB_TIMEOUT=0` hides the menu.  
**Fix:**
```bash
sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub
# Regenerate (choose correct path per system):
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# or (UEFI CentOS):
sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
```

---

## 2) Can't edit GRUB parameters
**Symptom:** Pressing **Enter** boots immediately; **e** doesn’t open editor.  
**Cause:** Menu timed out or wrong key.  
**Fix:** Interrupt timeout by pressing any key quickly; select kernel entry, press **e**; boot with **Ctrl+X** (or **F10**).

---

## 3) Changes to `/etc/default/grub` don't take effect
**Symptom:** Kernel cmdline unchanged after reboot.  
**Cause:** Forgot to regenerate `grub.cfg` or used wrong path.  
**Fix:**
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# or /boot/efi/EFI/centos/grub.cfg (UEFI)
```
**Verify:**
```bash
grep ^GRUB_CMDLINE_LINUX /etc/default/grub
sudo awk '/^linux/ {print}' $(find /boot -name grub.cfg | head -1) | head -1
```

---

## 4) Boot failure after editing `/etc/fstab`
**Symptom:** Boot drops to *emergency*/*rescue*, errors reference a bad mount.  
**Cause:** Invalid device/options in `/etc/fstab`.  
**Fix (from rescue/emergency):**
```bash
mount -o remount,rw /
sed -i '/nonexistent/d' /etc/fstab
# or
cp /etc/fstab.backup /etc/fstab
```
Reboot and re‑test.

---

## 5) `chronyd` unit missing/masked
**Symptom:** `systemctl status chronyd` shows "not-found" or "masked".  
**Cause:** Package not installed or service masked.  
**Fix:**
```bash
sudo dnf install -y chrony
sudo systemctl unmask chronyd
sudo systemctl enable --now chronyd
```

---

## 6) SSH service fails due to OpenSSL mismatch (from a previous lab host)
**Symptom:**
```
/usr/sbin/sshd -t
OpenSSL version mismatch. Built against 30000010, you have 30200020
```
**Fix options:**
```bash
sudo dnf reinstall -y openssl openssh openssh-server
sudo dnf distro-sync -y
sudo systemctl enable --now sshd
```
(If a custom OpenSSL was installed, revert to distro default.)

---

## 7) `systemctl` unusable in containers
**Symptom:** `System has not been booted with systemd as init system (PID 1).`  
**Cause:** Running in a container without systemd.  
**Fix:** Use a proper VM. This lab requires bootloader/kernel control.

---

## Validation
- `systemctl list-units --type=service --state=active`
- `systemctl get-default` shows expected target
- Temporary `systemd.unit=…` from GRUB works
- `grub.cfg` updated after edits
- Rescue/Emergency modes reachable; `/etc/fstab` issue fixable
