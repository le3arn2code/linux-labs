# Troubleshooting — Lab 17 (journalctl / systemd-journald)

> In this packaged run, no blocking errors occurred. Below are **common, realistic issues** you may hit and how to resolve them quickly.

---

## 1) Persistent logs not available after reboot
**Symptoms**
- `/var/log/journal/` does not exist, or survives but is empty after reboot.
**Fix**
```bash
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

## 2) `systemd-journald` fails to restart due to config error
**Symptom**
```
Job for systemd-journald.service failed because the control process exited with error code.
```
**Fix**
- Validate `journald.conf` for typos/unknown keys.
- Revert using the backup:
  ```bash
  sudo cp /etc/systemd/journald.conf.backup /etc/systemd/journald.conf
  sudo systemctl restart systemd-journald
  ```

## 3) Disk usage too high / fast growth
**Diagnosis**
```bash
journalctl --disk-usage
```
**Mitigation**
- Tune limits in `/etc/systemd/journald.conf` (e.g., `SystemMaxUse`, `SystemKeepFree`).
- Clean old logs:
  ```bash
  sudo journalctl --vacuum-size=200M
  sudo journalctl --vacuum-time=7d
  sudo journalctl --vacuum-files=30
  ```

## 4) Can't see logs for a service
**Symptom**
```
journalctl -u servicename
# no output
```
**Fix**
- Verify the unit name and that it is logging:
  ```bash
  systemctl list-units --type=service | grep -i servicename
  journalctl -u servicename.service --since today
  ```

## 5) Permission denied / insufficient output
- Run with elevated privileges for full visibility:
  ```bash
  sudo journalctl ...
  ```
- Unprivileged users may need to be in the `systemd-journal` group.

## 6) Timezone or clock confusion
- Journal shows timestamps in local time by default; use UTC if desired:
  ```bash
  journalctl --utc -n 20
  timedatectl
  ```

## 7) Corrupted journal files
**Diagnosis**
```bash
sudo journalctl --verify
```
**Fix**
- Rotate/clean problematic files:
  ```bash
  sudo journalctl --vacuum-time=2d
  ```
- If persistent corruption persists, stop journald, move broken files out of the way, then start again.

## 8) Not seeing previous boot
- There may be no prior boots (fresh VM/container) or persistence was disabled.
- Confirm with:
  ```bash
  journalctl --list-boots
  ```

## 9) SELinux preventing writes (rare)
- Check AVCs:
  ```bash
  sudo ausearch -m avc -ts recent | audit2why
  ```
- Ensure `/var/log/journal` has correct context:
  ```bash
  ls -Z /var/log | grep journal
  restorecon -Rv /var/log/journal
  ```

## 10) Forwarding to syslog or console still happening
- Verify effective settings:
  ```bash
  systemctl show systemd-journald | grep -E '(Storage|MaxUse|KeepFree|ForwardTo)'
  ```
- Edit `/etc/systemd/journald.conf`, then restart `systemd-journald`.

---

### Quick Checks
```bash
systemctl status systemd-journald --no-pager
journalctl --disk-usage
journalctl --verify
journalctl -p err --since "1 hour ago" -n 20
journalctl -u sshd -p warning --since today -n 50
```
