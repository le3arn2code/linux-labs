# Interview Q&A — journalctl & systemd-journald (10)

**1) What advantages does the systemd journal have over traditional flat log files?**  
Centralized, structured logs with indexed fields (e.g., `_PID`, `_SYSTEMD_UNIT`, `_HOSTNAME`), binary storage, powerful filtering, and boot scoping. It reduces parsing overhead and improves searchability.

**2) How do you enable persistent logging?**  
Create `/var/log/journal`, ensure correct perms, set `Storage=persistent` in `/etc/systemd/journald.conf`, then restart `systemd-journald`. Verify with `journalctl --disk-usage` and presence of journal files under `/var/log/journal/<machine-id>/`.

**3) Explain journal priorities. How do you filter by them?**  
Priorities: `0 emerg`..`7 debug`. Filter with `journalctl -p <level>` (inclusive). Example: `journalctl -p warning` shows warning and higher (warning..emerg).

**4) How do you get logs for a specific unit, PID, or boot?**  
- Unit: `journalctl -u sshd`  
- PID: `journalctl _PID=1234`  
- Boot: `journalctl -b -1` (previous boot), `journalctl --list-boots` (index list).

**5) What is the difference between runtime and persistent journals?**  
Runtime is stored under `/run/log/journal` (tmpfs) and lost at reboot. Persistent is under `/var/log/journal` and survives reboots.

**6) How do you export logs for offline analysis?**  
Use machine-readable formats: `journalctl --since today --output=json > today_logs.json` or `-o json-pretty`, `-o export` for binary export/import with `journalctl --file`.

**7) How do you limit journal disk usage?**  
Tune `/etc/systemd/journald.conf` (`SystemMaxUse`, `SystemKeepFree`, `SystemMaxFileSize`, `MaxRetentionSec`) and/or run `journalctl --vacuum-size=500M` or `--vacuum-time=7d`.

**8) How can you monitor and alert on critical messages?**  
Use `journalctl -p crit --since "5 minutes ago"` in a cron/systemd timer; or build a script (see `log_monitor.sh`) that appends to an alert file and integrates with email/webhooks.

**9) How does journald interact with rsyslog?**  
By default on many distros journald forwards to the syslog socket. You can control this via `ForwardToSyslog=` in `journald.conf`. Many setups use journald for collection and rsyslog for forwarding to remote aggregators (e.g., ELK).

**10) Who can read the journal and how to extend access securely?**  
Root has full access. Non-root users may read their own logs. To allow broader read access, add the user to the `systemd-journal` group or use `journalctl --user` for user-level services; always follow least-privilege principles.
