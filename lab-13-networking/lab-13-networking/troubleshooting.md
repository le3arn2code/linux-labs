# troubleshooting.md — Errors We Hit & How We Fixed Them (Lab 13)

We followed the lab **exactly**. Here are the issues that occurred and how we resolved them, with the final working commands.

---

## 1) `eth0` not found / wrong interface name
**Symptom:** `Error: Device 'eth0' not found.`  
**Cause:** Cloud images often use `ens*`/`enp*` names.  
**Fix:**
```bash
nmcli device status
# Use the NAME shown (e.g., ens33) in place of eth0 in all lab commands.
```
**Final command example:**
```bash
sudo nmcli connection add type ethernet con-name "static-connection" ifname ens33 ip4 192.168.1.100/24 gw4 192.168.1.1
```

---

## 2) Connection activation failed due to a conflicting auto-connected profile
**Symptom:**
```
Error: Connection activation failed: No suitable device found for this connection...
```
or IP conflict / still on DHCP.  
**Cause:** Default “Wired connection 1” (DHCP) is auto‑connected.  
**Fix:**
```bash
nmcli connection show
sudo nmcli connection down "Wired connection 1"  # or whatever name is active DHCP
sudo nmcli connection up "static-connection"
```
(Optionally disable autoconnect on the conflicting profile.)

---

## 3) No Internet after static assignment
**Symptom:** `ping 8.8.8.8` fails, no default route or wrong gateway.  
**Fix:**
```bash
ip route show
# Ensure default via 192.168.1.1 is present
sudo nmcli connection modify "static-connection" ipv4.gateway 192.168.1.1
sudo nmcli connection up "static-connection"
```
If DNS fails but ping to IP works, set DNS:
```bash
sudo nmcli connection modify "static-connection" ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli connection up "static-connection"
```

---

## 4) `ip addr show eth0` shows old address after switching
**Symptom:** IP doesn’t change after `nmcli connection up backup-connection`.  
**Cause:** Old profile still active / device bound to previous profile.  
**Fix:**
```bash
sudo nmcli device disconnect eth0    # replace with your interface
sudo nmcli connection up "backup-connection"
ip addr show eth0
```

---

## 5) `nslookup` / `dig` not found
**Symptom:** `bash: nslookup: command not found` or `dig: command not found`.  
**Fix (RHEL 8/9):**
```bash
sudo dnf install -y bind-utils
```
Re‑run the resolution tests.

---

## 6) Hostname not persisting / not reflected in tools
**Symptom:** `hostnamectl status` shows old name after reboot, or `hostname -f` empty.  
**Causes:** Wrong permissions on `/etc/hostname`, stale hostnamed cache, missing hosts entry.  
**Fix:**
```bash
sudo chmod 644 /etc/hostname
sudo systemctl restart systemd-hostnamed
# Ensure /etc/hosts has the static IP -> names mapping from the lab.
```
**Verify:**
```bash
hostnamectl status
hostname -f
```

---

## 7) `ping lab-server-01` fails
**Symptom:** Hostname resolution fails for the lab host.  
**Fix:** Confirm `/etc/hosts` contains:
```
192.168.1.100    lab-server-01.localdomain    lab-server-01
```
If you used a different interface/IP, update the IP accordingly.

---

## 8) NetworkManager inactive or unmanaged
**Symptom:** `systemctl status NetworkManager` shows inactive/failed; `nmcli` changes don’t apply.  
**Fix:**
```bash
sudo systemctl enable --now NetworkManager
```
If interfaces are set to `unmanaged`, check `/etc/NetworkManager/NetworkManager.conf` and remove unmanaged rules, then:
```bash
sudo systemctl restart NetworkManager
```

---

## 9) Route/device busy on switch
**Symptom:** Errors when bringing connections up/down.  
**Fix:**
```bash
sudo nmcli device disconnect eth0
sudo nmcli connection up "backup-connection"
```

---

## 10) Connectivity blocked by security policy
**Symptom:** `ping google.com` fails while DNS works.  
**Cause:** ICMP blocked outbound by network policy.  
**Workaround for verification:** Use TCP‑based tests:
```bash
curl -I https://www.google.com
```

---

## Final verification (after fixes)
```bash
nmcli connection show --active
ip addr show
ip route show
cat /etc/hostname; hostnamectl status; hostname -f
ping -c 4 8.8.8.8
ping -c 4 google.com
nslookup google.com; dig google.com
```
