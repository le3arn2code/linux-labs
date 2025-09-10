# troubleshooting.md — Errors We Hit & How We Fixed Them (Lab 14)

We followed the lab **exactly**. These are the issues that occurred during execution and how we resolved each one. For every case, the **final working commands** are shown.

---

## 1) `traceroute: command not found`
**Symptom:** `bash: traceroute: command not found`  
**Cause:** Package not installed.  
**Fix (as per lab):**
```bash
sudo dnf install -y traceroute || sudo yum install -y traceroute
```
**Verify:** `traceroute -n 8.8.8.8` prints hop list.

---

## 2) `nslookup: command not found`
**Symptom:** `bash: nslookup: command not found`  
**Cause:** `bind-utils` missing on RHEL/CentOS.  
**Fix:**
```bash
sudo dnf install -y bind-utils || sudo yum install -y bind-utils
```
**Verify:** `nslookup google.com` returns A records and DNS server info.

---

## 3) Connection name `"System eth0"` does not exist
**Symptom:**
```
Error: Unknown connection: System eth0
```
**Cause:** Actual profile has a different name (e.g., `Wired connection 1`), or interface is `ens*/enp*`.  
**Fix:**
```bash
nmcli connection show
# Use the real connection name in all 'nmcli connection modify' commands.
```
**Final command example:**
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli connection up "Wired connection 1"
```

---

## 4) No default gateway / cannot ping external IP
**Symptom:** `ping 8.8.8.8` fails; `ip route show` lacks `default` route.  
**Fix:**
```bash
sudo nmcli connection modify "<your-connection>" ipv4.gateway 192.168.1.1
sudo nmcli connection modify "<your-connection>" ipv4.method manual
sudo nmcli connection up "<your-connection>"
```
**Verify:** `ip route show` includes `default via 192.168.1.1`.

---

## 5) DNS works inconsistently / cannot resolve names
**Symptom:** `ping 8.8.8.8` OK but `ping google.com` fails.  
**Fix:**
```bash
cat /etc/resolv.conf
sudo nmcli connection modify "<your-connection>" ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli connection up "<your-connection>"
```
**Verify:** `nslookup google.com` resolves; `ping google.com` succeeds.

---

## 6) `firewall-cmd: command not found` or firewalld inactive
**Symptom:** `bash: firewall-cmd: command not found` or `inactive (dead)`.  
**Fix:**
```bash
# install if needed
sudo dnf install -y firewalld || sudo yum install -y firewalld
sudo systemctl enable --now firewalld
```
**Verify:** `sudo firewall-cmd --state` returns `running`.

---

## 7) Opened service/port but traffic still blocked
**Symptom:** After `--add-service=http` or `--add-port=8080/tcp`, service still unreachable.  
**Causes:** Forgot `--permanent && --reload`, wrong zone, service bound to 127.0.0.1 only.  
**Fix:**
```bash
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload
# ensure the app listens on 0.0.0.0:8080 (or correct IP)
sudo ss -tulpen | grep ':8080'
```
**Verify:** Remote host can connect; `sudo firewall-cmd --zone=public --list-ports` shows entries.

---

## 8) `netstat` not available during Scenario 2
**Symptom:** `bash: netstat: command not found`.  
**Fix:** Install **net-tools**, or use `ss` as a diagnostic (not a deviation from lab results but helpful in practice):
```bash
sudo dnf install -y net-tools || sudo yum install -y net-tools
# Alternative:
sudo ss -tlnp | grep 8080
```
**Verify:** Listening process is visible.

---

## 9) Interface `eth0` not present
**Symptom:** `sudo nmcli connection add ... ifname eth0` fails.  
**Fix:**
```bash
nmcli device status
# Replace 'eth0' with actual device (e.g., ens33) in add/modify commands.
```
**Final command example:**
```bash
sudo nmcli connection add type ethernet con-name "lab-connection" ifname ens33
```

---

## 10) ICMP Echo blocked by network policy
**Symptom:** `ping` to external hosts fails but TCP/HTTPS works.  
**Fix/Workaround:** Use TCP checks instead of ICMP when verifying connectivity:
```bash
curl -I https://www.google.com
traceroute -T -p 443 google.com  # TCP traceroute if available
```

---

## Final verification commands
```bash
nmcli connection show --active
ip addr show; ip route show
sudo firewall-cmd --state; sudo firewall-cmd --list-all
ping -c 4 8.8.8.8 && ping -c 4 google.com
nslookup google.com
traceroute -n 8.8.8.8
```
