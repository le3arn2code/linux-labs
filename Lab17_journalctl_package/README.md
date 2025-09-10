# Lab 17 — Using `journalctl` for Log Analysis

This repo contains a **GitHub-ready** package for Lab 17. It includes:
- `README.md` (you are here)
- `commands.sh` (idempotent, step-by-step commands following the lab exactly)
- `troubleshooting.md` (likely errors + fixes)
- `interview_qna.md` (10 Q&A with complete answers)

> Target OS: **RHEL/CentOS 8 or 9** with **systemd**.  
> Requires `sudo` privileges.

---

## Objectives
- Understand the systemd journal and its advantages over traditional logs
- Use `journalctl` to view and navigate logs
- Filter logs by **time**, **priority**, and **unit**
- Configure **persistent** journal storage
- Apply log analysis techniques for troubleshooting and monitoring

## Prerequisites
- Linux CLI basics
- Familiarity with systemd units/services
- Understanding of log levels (emerg..debug)
- RHEL/CentOS 8/9 machine with `sudo`

## Quick Start
```bash
# 1) Run the scripted lab (safe to re-run)
chmod +x commands.sh
sudo ./commands.sh

# 2) Explore results
journalctl -n 20
journalctl --disk-usage
sudo systemctl status systemd-journald --no-pager
```

## What the Script Does (High Level)
1. Shows core `journalctl` help and **basic viewing** commands.
2. Demonstrates **output formats** (short/json/verbose).
3. Runs **time-, priority-, and unit-based filtering**.
4. Combines filters for targeted diagnostics.
5. Sets up **persistent storage** exactly as in the lab (with a backup of `journald.conf`).
6. Verifies persistence, **generates test entries**, and shows **vacuum** options.
7. Adds a tiny **monitoring script** that logs critical-error summaries.
8. Provides verification commands and hints for further analysis.

## Verification Cheatsheet
```bash
# journal status and usage
systemctl status systemd-journald --no-pager
journalctl --disk-usage
journalctl --verify

# common filters
journalctl -p warning --since "1 hour ago" -n 5
journalctl -u sshd -p err --since today
journalctl -b 0 -n 20    # current boot

# persistence
ls -la /var/log/journal/
journalctl --list-boots | head -5
```

## Notes about “Errors We Hit”
For this packaged run, **no blocking errors** occurred. Real environments may differ;  
we documented the **most common issues** and exact fixes in **`troubleshooting.md`**.

---

**Why this matters:** The systemd journal gives structured, queryable logs across kernel, services, and apps, making troubleshooting and auditing faster and more reliable. See **`interview_qna.md`** for exam-style questions and concise answers.
