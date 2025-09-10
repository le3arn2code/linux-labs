# Interview Q&A — firewalld (10)

**1) What is firewalld and how does it differ from iptables?**  
Firewalld is a **high‑level firewall manager** using **nftables** (RHEL 8/9) as backend. It provides **zones**, **services**, and **runtime vs. permanent** separation. Iptables directly manipulates packet filter rules; firewalld abstracts this with a coherent API (`firewall-cmd`).

**2) What are zones? How are they used?**  
Zones are **trust levels** (e.g., `public`, `internal`, `dmz`) that group rules. You **assign interfaces or sources to zones**, then add services/ports/rich rules to that zone to control traffic for those networks.

**3) Difference between runtime and permanent configurations?**  
- **Runtime** changes (no `--permanent`) apply immediately and **reset on reload/reboot**.  
- **Permanent** changes persist; you **must `--reload`** to apply to runtime.

**4) Services vs. ports in firewalld?**  
A **service** is a named bundle (ports + protocols) defined in XML (e.g., `http`, `https`, `ssh`). Opening a **port** is explicit (`--add-port=8080/tcp`). Prefer **services** for maintainability; use ports for custom apps.

**5) How do rich rules work?**  
Rich rules provide **fine‑grained control** (match on source, protocol, service/port, log, limit). Example:  
```bash
firewall-cmd --permanent --add-rich-rule='rule source address="192.168.1.0/24" service name="ssh" accept'
```

**6) How do you find which zone is affecting an interface?**  
```bash
firewall-cmd --get-active-zones
```
Then inspect with `--zone=ZONENAME --list-all`. The **default zone** applies to unassigned interfaces.

**7) How do you safely test strict rules on a remote server?**  
- Make **runtime** changes first.  
- Keep an **existing SSH session** open.  
- Use **`--timeout`** on rules (if available) or plan a **maintenance window**.  
- Have console/ILO/VM access to revert.

**8) How do you log drops or rate‑limit SSH?**  
```bash
# Log all drops
firewall-cmd --permanent --add-rich-rule='rule drop log prefix="FIREWALL-DROP: " level="warning"'

# Rate limit SSH
firewall-cmd --permanent --add-rich-rule='rule service name="ssh" accept limit value="3/m"'
firewall-cmd --reload
```
Check logs with `journalctl -u firewalld -f`.

**9) How does firewalld interact with SELinux?**  
They are **complementary**. Firewalld filters **network flows**; SELinux controls **process/file access**. You might open port 80 in firewalld but still need SELinux booleans/contexts (e.g., `setsebool -P httpd_can_network_connect 1`).

**10) How to expose a custom app on port 3001 only to an internal subnet?**  
```bash
firewall-cmd --permanent --zone=internal --add-port=3001/tcp
firewall-cmd --permanent --zone=internal --add-source=192.168.1.0/24
firewall-cmd --reload
```
(Or use a **rich rule** to accept from that source and drop elsewhere.)
