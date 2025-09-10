# troubleshooting.md — Errors We Hit & How We Fixed Them

This lab captured the *actual* issues we encountered during setup and how we resolved them. Each includes the final, correct commands to verify.

---

## 1) Terminal “freezes” after `crontab -e`
**Symptom:** Terminal appears stuck; after saving, subsequent terminals also “hang”.  
**Causes:**
- The TTY was flow‑controlled with **Ctrl+S** (XON/XOFF).  
- The editor was still open (nano/vi/less).  
- A cron job spawned a long‑running command (e.g., `tail -f`) every minute.

**Fix:**
```bash
# Unpause
Ctrl+Q

# Reset terminal
stty sane; stty -ixon

# If a runaway job is suspected, stop cron, kill the job, and restart
sudo systemctl stop crond
pkill -f 'log_monitor.sh|tail -f' || true
sudo systemctl start crond
```
**Verify:** `crontab -l` shows the entries; `sudo systemctl status crond` is active.

---

## 2) First‑time `crontab -e` prints “no crontab ... installing new crontab”
**Symptom:** Message appears and session looks stuck.  
**Root cause:** Normal behavior on the first edit; the editor is waiting for you.  
**Fix:** Edit/save/quit normally (`nano`: **Ctrl+X**, `Y`; `vi`: `:wq`).  
**Verify:** `crontab -l` shows your new entry.

---

## 3) `systemctl --user` fails: `Failed to get D-Bus connection: No such file or directory`
**Symptom:** User‑level timers (`systemctl --user ...`) cannot be enabled/started.  
**Root cause:** No per‑user systemd manager (no user D‑Bus).  
**Fix:**
```bash
# as root
loginctl enable-linger centos
systemctl start "user@$(id -u centos).service"

# re-login as centos, then:
systemctl --user daemon-reload
systemctl --user enable --now personal-backup.timer
systemctl --user list-timers
```
**Verify:** `systemctl --user list-timers` shows `personal-backup.timer` with a next run time.

---

## 4) Created a `.timer` without a matching `.service`
**Symptom:** Timer exists but nothing executes at run time.  
**Root cause:** The `.service` unit the timer requires didn’t exist.  
**Fix:**
```bash
# Create the service (example for temp cleanup)
sudo tee /etc/systemd/system/temp-cleanup.service << 'EOF'
[Unit]
Description=Temporary Files Cleanup Service
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/usr/local/bin/temp-cleanup.sh
User=root
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now temp-cleanup.timer
```
**Verify:** `systemctl list-timers | grep temp-cleanup` shows last/next; `journalctl -u temp-cleanup.service -n 20` shows runs.

---

## 5) Permission errors writing logs under `/var/log`
**Symptom:** Service writes fail when `User` is not root.  
**Fix:** Ensure the system service specifies `User=root` (as in the lab) **or** write to a user‑writable path.  
**Verify:** `sudo tail /var/log/system-status.log` and `/var/log/temp-cleanup.log` show entries.

---

## 6) Cron job works manually but not via cron
**Causes:** Missing PATH/env, relative paths, permissions.  
**Fix:** Use absolute paths (as in the lab), ensure scripts are `chmod +x`, and redirect output:
```bash
*/10 * * * * /home/centos/scripts/log_monitor.sh >> /home/centos/cron_monitor.log 2>&1
```
**Verify:** Check target logs and `/var/log/cron`.

---

## 7) Duplicate report blocks in `system_reports.log`
**Symptom:** Two identical blocks with the same timestamp.  
**Root cause:** Script run twice (manual + cron) within the same minute, and it appends (`>>`).  
**Fix:** Expected when testing; clear log and re‑test:
```bash
: > ~/system_reports.log
~/scripts/system_info.sh
```

---

## Final validation commands
```bash
sudo systemctl status crond
crontab -l
systemctl list-timers --all
sudo journalctl -u system-status.timer -n 10 --no-pager
sudo journalctl -u system-status.service -n 10 --no-pager
sudo tail -n 50 /var/log/system-status.log
sudo systemctl start temp-cleanup.service
sudo tail -n 50 /var/log/temp-cleanup.log
systemctl --user list-timers  # after enabling user lingering
```
