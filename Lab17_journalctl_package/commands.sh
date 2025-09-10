#!/usr/bin/env bash
# Lab 17 - Using journalctl for Log Analysis
# This script follows the lab steps closely and is safe to re-run.
set -euo pipefail

log() { printf "\n\033[1;36m[LAB17]\033[0m %s\n" "$*"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "[LAB17] Please run as root (sudo ./commands.sh)"
    exit 1
  fi
}

require_root

log "Task 1: View Logs with journalctl — Understanding the systemd Journal"
# Step 1: (already root)
# Step 2: Basic help (first 20 lines)
journalctl --help | head -20 || true
# Step 3: Display all journal entries (pager will be suppressed with --no-pager to avoid blocking)
journalctl --no-pager -n 50 || true

log "Subtask 1.2: Basic Log Viewing Commands"
journalctl -n || true           # last 10
journalctl -n 20 || true        # last 20
# Follow mode (in scripts we avoid blocking; show a sample of how it would be called)
# journalctl -f
journalctl -r -n 20 || true     # newest first
journalctl --no-pager -n 5 || true

log "Subtask 1.3: Output Formats"
journalctl -o json -n 3 --no-pager || true
journalctl -o verbose -n 2 --no-pager || true
journalctl -o short -n 5 --no-pager || true

log "Task 2: Filter Logs — Time-Based"
journalctl --since today -n 10 --no-pager || true
journalctl --since yesterday --until today -n 10 --no-pager || true
journalctl --since "1 hour ago" -n 10 --no-pager || true
journalctl --since "2024-01-01 00:00:00" --until "2024-01-01 23:59:59" --no-pager || true
journalctl --since "30 minutes ago" -n 10 --no-pager || true

log "Task 2: Filter Logs — Priority-Based"
# priority levels: 0 emerg .. 7 debug
journalctl -p err --no-pager -n 10 || true
journalctl -p warning --no-pager -n 10 || true
journalctl -p crit --no-pager -n 10 || true
# generate test messages
logger -p user.err "This is a test error message"
logger -p user.warning "This is a test warning message"
logger -p user.info "This is a test info message"
journalctl -p info --since "1 minute ago" --no-pager | grep -E "test (error|warning|info) message" || true

log "Task 2: Filter Logs — Unit-Based"
journalctl -F _SYSTEMD_UNIT --no-pager | head -10 || true
journalctl -u sshd --no-pager -n 20 || true
journalctl -u NetworkManager --no-pager -n 20 || true
journalctl -u sshd -u NetworkManager --since today --no-pager -n 50 || true
journalctl -k --no-pager -n 20 || true
# by PID (use PID 1 as an example if present)
if [[ -e /proc/1/status ]]; then
  journalctl _PID=1 -n 5 --no-pager || true
fi

log "Task 2: Combining Filters"
journalctl -u sshd -p err --since today --no-pager || true
journalctl -p warning --since "2 hours ago" --no-pager || true
journalctl -u NetworkManager -p info --since yesterday --until today --no-pager || true

log "Task 3: Set Up Persistent Log Storage — Inspect"
journalctl --disk-usage || true
cat /etc/systemd/journald.conf | sed -n '1,80p' || true
ls -la /var/log/journal/ || true || true

log "Task 3: Enable Persistent Storage (with backup)"
mkdir -p /var/log/journal
chown root:systemd-journal /var/log/journal
chmod 2755 /var/log/journal

# Backup journald.conf once per run (kept for reference)
if [[ ! -f /etc/systemd/journald.conf.backup ]]; then
  cp /etc/systemd/journald.conf /etc/systemd/journald.conf.backup
fi

# Write the lab's configuration block exactly as specified
cat > /etc/systemd/journald.conf << 'EOF'
[Journal]
Storage=persistent
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=50M
MaxRetentionSec=1month
MaxFileSec=1week
ForwardToSyslog=no
ForwardToKMsg=no
ForwardToConsole=no
ForwardToWall=yes
EOF

systemctl restart systemd-journald
systemctl status systemd-journald --no-pager || true

log "Task 3: Verify Persistence"
ls -la /var/log/journal/ || true
# show potential machine-id subdir content if present
ls -la /var/log/journal/*/ 2>/dev/null || true
journalctl --disk-usage || true
for i in {1..10}; do logger "Test persistent log entry $i"; done
journalctl --since "1 minute ago" --no-pager | grep "Test persistent" || true

log "Task 3: Manage Journal Storage"
journalctl --disk-usage || true
journalctl --verify || true
journalctl --vacuum-time=2d || true
journalctl --vacuum-size=100M || true
journalctl --vacuum-files=50 || true
systemctl show systemd-journald | grep -E '(Storage|MaxUse|KeepFree)' || true

log "Task 4: Advanced Filtering and Analysis"
journalctl --no-pager | grep -i "error" | head -10 || true
journalctl -g "failed" --no-pager | head -10 || true
journalctl _UID=0 -n 10 --no-pager || true
journalctl --list-boots --no-pager | head -10 || true
journalctl -b 0 -n 20 --no-pager || true
# previous boot (may not exist in containers/VMs)
journalctl -b -1 -n 10 --no-pager || true
journalctl --since today --output=json > /tmp/today_logs.json

log "Task 4: Monitoring & Alerting — Create a simple monitor script"
cat > /usr/local/bin/log_monitor.sh << 'EOF'
#!/bin/bash
# Simple log monitoring script for critical errors
LOGFILE="/var/log/critical_alerts.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
CRITICAL_COUNT=$(journalctl -p crit --since "5 minutes ago" --no-pager | wc -l)
if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "[$TIMESTAMP] ALERT: $CRITICAL_COUNT critical errors found in the last 5 minutes" >> "$LOGFILE"
  journalctl -p crit --since "5 minutes ago" --no-pager >> "$LOGFILE"
fi
EOF
chmod +x /usr/local/bin/log_monitor.sh
/usr/local/bin/log_monitor.sh || true
logger -p user.crit "Test critical error for monitoring"
/usr/local/bin/log_monitor.sh || true
tail -n 20 /var/log/critical_alerts.log || true

log "Verification & Testing — Final checks"
systemctl status systemd-journald --no-pager || true
ls -la /var/log/journal/ || true
journalctl --disk-usage || true
journalctl -p warning --since "1 hour ago" -n 5 --no-pager || true

log "Generate Lab 17 verification messages"
logger -p user.info "Lab 17 verification: Info message"
logger -p user.warning "Lab 17 verification: Warning message"
logger -p user.err "Lab 17 verification: Error message"
echo "=== Testing priority filtering ==="
journalctl -p warning --since "1 minute ago" --no-pager | grep "Lab 17" || true
echo "=== Testing time filtering ==="
journalctl --since "1 minute ago" --no-pager | grep "Lab 17" || true
echo "=== Testing persistent storage (journal files) ==="
ls -la /var/log/journal/*/system.journal 2>/dev/null || true

log "DONE. Lab 17 configuration and demonstrations completed successfully."
