# interview_qna.md — 10 Cron & systemd Timers Questions **with Answers**

### 1) When would you use cron vs. systemd timers?
**Answer:** Use **cron** for simple per‑user scheduling with minimal dependencies. Use **systemd timers** for richer control (dependencies, unit isolation, logging via journal, persistent timers, accuracy, randomized delays) and for system‑level automation.

### 2) What does “Persistent=true” do in a timer?
**Answer:** It runs the missed job **once** at the next opportunity if the system was off/asleep at the scheduled time (catch‑up behavior).

### 3) How do you test a timer quickly?
**Answer:** Start the **service** directly: `sudo systemctl start <name>.service`; check logs: `journalctl -u <name>.service -e`. Or set `OnActiveSec=10s` in a temporary test timer.

### 4) Where do cron and systemd timers log output?
**Answer:** Cron mails output to the user by default or wherever you redirect (`>> file 2>&1`). systemd services log to the **journal** (`journalctl -u <svc>`), plus any files your script writes to.

### 5) Why might a cron job run manually but fail in cron?
**Answer:** Cron has a minimal environment and different `PATH`. Fix with absolute paths, exporting env vars in the script, setting permissions, and ensuring non‑interactive commands.

### 6) How do you list and see the next run of timers?
**Answer:** `systemctl list-timers --all` for all timers; `systemctl list-timers <timer>` or `systemctl status <timer>` for a specific timer’s next/last runs.

### 7) How do you ensure a systemd timer runs as a specific user?
**Answer:** In the **service** unit, set `User=<name>`. For per‑user timers, use `systemctl --user` units and enable **lingering** so they run without an active session.

### 8) How can you avoid thundering‑herd effects with many timers?
**Answer:** Use `RandomizedDelaySec=` in the timer, and/or `OnUnitActiveSec=` with spread. This staggers start times.

### 9) What are common cron time fields gotchas?
**Answer:** `*/N` granularity depends on the field; **day‑of‑week** and **day‑of‑month** together are **OR**, not AND; beware of local time vs UTC; ensure newline at end of crontab file.

### 10) How do you debug a failing systemd service launched by a timer?
**Answer:** `systemctl status <svc>`, `journalctl -u <svc>`, run the ExecStart by hand, verify permissions/paths, add `Environment=` or a wrapper script with verbose logging, and use `systemd-analyze verify <unit>` to spot unit syntax errors.
