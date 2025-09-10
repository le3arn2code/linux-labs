# Lab 16 — Configuring firewalld for Network Security

This repo contains a **GitHub‑ready** package for Lab 16. It includes:
- `README.md` (you are here)
- `commands.sh` (idempotent, step‑by‑step commands)
- `troubleshooting.md` (all common errors + fixes)
- `interview_qna.md` (10 Q&A with clear, concise answers)

> Target OS: **RHEL/CentOS 8 or 9** (nftables backend).  
> Requires `sudo` privileges.

---

## Objectives
By the end of this lab you will be able to:
- Understand firewalld fundamentals and zones
- Install, start, and enable the `firewalld` service
- Create and manage rules (services, ports, ranges)
- Configure zones and assign interfaces
- Manage services/ports within zones
- Test your configuration with curl/nmap/nc
- Implement secure communication policies via zones and rich rules
- Troubleshoot common firewall issues

## Prerequisites
- Basic Linux CLI literacy
- Familiarity with IPs/ports/protocols
- Knowledge of network services (SSH/HTTP/HTTPS)
- RHEL/CentOS 8 or 9 machine with internet access and `sudo`

## Quick Start
```bash
# 1) Run the scripted lab (safe & idempotent)
chmod +x commands.sh
sudo ./commands.sh

# 2) Explore results
sudo firewall-cmd --list-all
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-rich-rules
```

## What the Script Does (High Level)
1. Ensures **firewalld** and test tools are installed.
2. Starts/enables **firewalld** and resolves **iptables** conflicts if present.
3. Applies **basic rules** (HTTP/HTTPS, port 8080, range 3000–3005).
4. Applies **advanced rules** (sources, rich rules, rate-limiting, logging).
5. Creates **custom zone `webserver`**, assigns the active NIC to it, and adds services/ports.
6. Configures `internal` and `dmz` zones as per the lab.
7. Sets up **Apache httpd** and a **test page** for verification.
8. Runs a small battery of **tests** (curl, nmap, nc) and prints hints.
9. Shows **verification commands** and where to look for **logs**.

## Verification Cheatsheet
```bash
# firewalld status
sudo systemctl status firewalld --no-pager
sudo firewall-cmd --state

# default + active zones
sudo firewall-cmd --get-default-zone
sudo firewall-cmd --get-active-zones

# rules and rich rules
sudo firewall-cmd --list-all
sudo firewall-cmd --list-all --permanent
sudo firewall-cmd --list-rich-rules

# per-zone inspection
sudo firewall-cmd --zone=webserver --list-all
sudo firewall-cmd --zone=internal --list-all
sudo firewall-cmd --zone=dmz --list-all

# test ports
curl -I http://localhost || true
nmap -p 22,80,443,8080 localhost
nc -zv localhost 3306 || true
```

## Notes about “Errors We Hit”
For this packaged run, no _blocking_ errors occurred. In live environments you may still hit issues
(e.g., **iptables** service conflicts, missing packages, wrong interface name).  
We documented these thoroughly in **`troubleshooting.md`** with real error messages and fixes so you can reproduce and resolve them quickly.

## Cleanup (Optional)
```bash
# Remove the custom webserver zone and revert to defaults (non-destructive to other zones)
sudo firewall-cmd --permanent --delete-zone=webserver || true
sudo firewall-cmd --reload
sudo systemctl disable --now httpd || true
```

---

**Why this matters:** firewalld’s zone‑based model is the first line of defense on Linux servers.
It lets you apply precise policies per interface, per source, and per service with runtime vs. permanent separation and auditable rules.
See **`interview_qna.md`** for exam‑style Q&A.
