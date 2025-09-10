# troubleshooting.md — Errors We Hit & How We Fixed Them (Lab 15)

We followed the lab **exactly**. These are the issues we encountered, how we resolved them, and the **final working commands**.

---

## 1) `sudo echo ... > /home/testuser/website/index.html` failed with `Permission denied`
**Why:** Shell redirection (`>`) happens before `sudo`, so the file write ran as the unprivileged user.  
**Fix:** Use `tee` or a subshell with `sudo bash -c`.
```bash
# Corrected write (kept lab intent; just fixed redirection)
echo "<html><body>Test Page</body></html>" | sudo tee /home/testuser/website/index.html > /dev/null
# or
sudo bash -c 'echo "<html><body>Test Page</body></html>" > /home/testuser/website/index.html'
```

---

## 2) `semanage: command not found`
**Why:** `policycoreutils-python-utils` not installed.  
**Fix:**
```bash
sudo dnf install -y policycoreutils-python-utils setools-console
```
**Verify:** `which semanage` prints a path.

---

## 3) `semanage port -a ... 8080` error: *"ValueError: Port tcp/8080 already defined"*
**Why:** Port context already exists on the system.  
**Fix:** Modify instead of add, or skip if present.
```bash
# Modify if needed:
sudo semanage port -m -t http_port_t -p tcp 8080
# Verify:
semanage port -l | grep 8080
```

---

## 4) Apache could not read content from `/home/testuser/website` (403 / AVC denials)
**Symptoms:** `curl http://localhost/` returns 403; audit log shows `AVC denied` for type `user_home_t`.  
**Why:** Home directory content defaults to `user_home_t` which `httpd` cannot read.  
**Fix (per lab steps first):**
```bash
sudo semanage fcontext -a -t httpd_exec_t "/home/testuser/website(/.*)?"
sudo restorecon -R -v /home/testuser/website/
```
If denials persist, use the lab’s **alternative** (Step 38) to copy a correct context from `/var/www/html`:
```bash
sudo chcon --reference=/var/www/html /home/testuser/website/index.html
```
**Final verification:**
```bash
ls -Z /home/testuser/website/
curl http://localhost/
```

---

## 5) `sealert: command not found`
**Why:** `setroubleshoot-server` not installed on minimal images.  
**Fix:**
```bash
sudo dnf install -y setroubleshoot-server
sudo sealert -a /var/log/audit/audit.log
```

---

## 6) No denials found by `ausearch`
**Why:** Time range mismatch or `auditd` not running.  
**Fix:**
```bash
sudo systemctl enable --now auditd
sudo ausearch -m avc -ts recent
# Or broaden time:
sudo ausearch -m avc -ts today
```

---

## 7) `audit2allow -M myhttpd` failed: `checkpolicy: command not found`
**Why:** The policy module build requires **checkpolicy**.  
**Fix:**
```bash
sudo dnf install -y checkpolicy policycoreutils
sudo grep httpd /var/log/audit/audit.log | audit2allow -M myhttpd
sudo semodule -i myhttpd.pp
```

---

## 8) Duplicate fcontext rule errors when re‑running
**Symptom:** `semanage fcontext -a` returns *"already defined"*.  
**Fix:** Modify or delete then re‑add.
```bash
sudo semanage fcontext -m -t httpd_config_t "/opt/testapp/config.conf"
# or
sudo semanage fcontext -d "/opt/testapp/config.conf"
```

---

## 9) Apache restart failed after cleanup
**Why:** After removing test vhost/content, `httpd` may refer to missing paths.  
**Fix:** Remove `/etc/httpd/conf.d/testsite.conf` (already in cleanup) and restart:
```bash
sudo systemctl restart httpd
sudo systemctl status httpd
```

---

## 10) Confusion between **temporary** vs **persistent** boolean changes
**Note:** `setsebool on` is temporary; `-P` makes it persistent.  
**Final commands:**
```bash
sudo setsebool httpd_can_network_connect on
sudo setsebool -P httpd_can_network_connect on
getsebool httpd_can_network_connect
```

---

## Final verification
```bash
sestatus
getenforce
semanage fcontext -l | grep -E '/opt/testapp|/home/testuser/website' || true
semanage port -l | grep 8080 || true
getsebool httpd_can_network_connect
sudo ausearch -m avc -ts recent || true
curl -I http://localhost/ || true
```
