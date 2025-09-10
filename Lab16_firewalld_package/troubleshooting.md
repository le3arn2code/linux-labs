# Troubleshooting — Lab 16 (firewalld)

This document lists **common errors** you may encounter while configuring `firewalld`, with **exact messages** and **fixes**.

> In our scripted run for this package, no blocking errors were encountered. Below are realistic issues you might see in different RHEL/CentOS environments and how to resolve them quickly.

---

## 1) Firewalld service fails to start
**Symptom**
```
$ sudo systemctl start firewalld
Job for firewalld.service failed because the control process exited with error code.
```
**Likely causes & fixes**
- **iptables conflict**
  ```bash
  sudo systemctl status iptables
  sudo systemctl stop iptables
  sudo systemctl disable iptables
  sudo systemctl restart firewalld
  ```
- **Missing package**
  ```bash
  sudo dnf install -y firewalld
  sudo systemctl enable --now firewalld
  ```

## 2) Rules not taking effect
**Symptom**
```
$ sudo firewall-cmd --permanent --add-service=http
$ curl -I http://localhost
# still blocked
```
**Fix**
- Apply permanent changes with a reload:
  ```bash
  sudo firewall-cmd --reload
  ```
- Confirm the rule exists in the **permanent** config:
  ```bash
  sudo firewall-cmd --list-all --permanent
  ```
- Check your **default/active zone** and **interface assignment**:
  ```bash
  sudo firewall-cmd --get-default-zone
  sudo firewall-cmd --get-active-zones
  ```

## 3) Interface assigned to wrong zone
**Symptom**
```
$ sudo firewall-cmd --get-active-zones
public
  interfaces: ens160
# but you added rules to another zone
```
**Fix**
```bash
# Move interface to the intended zone
sudo firewall-cmd --permanent --zone=webserver --change-interface=ens160
sudo firewall-cmd --reload
```

## 4) Package not found (e.g., telnet)
**Symptom**
```
$ sudo dnf install -y telnet
No match for argument: telnet
```
**Fix**
- `telnet` is optional; use `nc`/`ncat` instead:
  ```bash
  sudo dnf install -y nmap nmap-ncat
  nc -zv localhost 8080
  ```

## 5) Port open but service unreachable
**Checklist**
- Is the service **running**?
  ```bash
  sudo systemctl status httpd --no-pager
  ```
- Is the service **listening**?
  ```bash
  sudo ss -tulpen | grep ':80'
  ```
- Is SELinux blocking?
  ```bash
  sudo ausearch -m avc -ts recent | audit2allow
  ```

## 6) Rich rule syntax error
**Symptom**
```
$ sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" accept limit value="3/m"'
Error: INVALID_RULE: ...
```
**Fix**
- Ensure proper quoting; run from **bash** (not fish/zsh) or escape quotes:
  ```bash
  sudo firewall-cmd --permanent --add-rich-rule="rule service name="ssh" accept limit value="3/m""
  sudo firewall-cmd --reload
  ```

## 7) nftables vs iptables confusion
RHEL 8/9 uses **nftables** under the hood. Avoid direct changes with legacy iptables tools; use `firewall-cmd` exclusively. If you *must* inspect low level rules:
```bash
sudo nft list ruleset | less
```

## 8) Lost access after strict rules
- Always **keep console access** or **second session** open while testing.
- Test with **runtime** changes first (no `--permanent`), then make permanent.
- If locked out remotely, use console/VM access to revert:
  ```bash
  sudo firewall-cmd --panic-off || true
  sudo firewall-cmd --reload
  ```

## 9) HTTP works locally but not remotely
- Ensure the server’s NIC is in the **expected zone**.
- Verify **cloud security groups / provider firewall** (EC2, Azure NSG, etc.).
- Check **routing** and **host firewalls** on the client side.

## 10) Logging drops
To see logs for drops (when using a logging rich rule):
```bash
sudo journalctl -u firewalld -f
# or system journal
sudo journalctl -f | grep FIREWALL-DROP
```

---

### Quick Diagnosis Bundle
```bash
sudo firewall-cmd --state
sudo firewall-cmd --get-default-zone
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all
sudo firewall-cmd --list-rich-rules
sudo nft list ruleset | sed -n '1,120p'
sudo ss -tulpen
sudo journalctl -u firewalld --since "15 min ago"
```
