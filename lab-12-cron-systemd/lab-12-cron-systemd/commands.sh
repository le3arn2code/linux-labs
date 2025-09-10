#!/usr/bin/env bash
# Lab 12 — Automating Tasks with Cron and systemd Timers (CentOS/RHEL 8/9)
# This follows the lab steps. Editor interactions (crontab -e) are manual.
set -euo pipefail

info(){ printf "\n==> %s\n" "$*"; }
pause(){ printf "\n[MANUAL STEP REQUIRED]\n%s\n" "$*"; }

# ----- Task 1.1: Explore cron
info "Check crond status"
sudo systemctl status crond || true
sudo systemctl start crond || true
sudo systemctl enable crond || true
crontab -l || true
ls -la /etc/cron* || true
cat /etc/crontab || true

# ----- Task 1.3: First cron job
info "Create system_info.sh"
mkdir -p ~/scripts
cat > ~/scripts/system_info.sh << 'EOF'
#!/bin/bash
# System Information Script
echo "=== System Information Report ===" >> ~/system_reports.log
echo "Date: $(date)" >> ~/system_reports.log
echo "Uptime: $(uptime)" >> ~/system_reports.log
echo "Disk Usage:" >> ~/system_reports.log
df -h >> ~/system_reports.log
echo "Memory Usage:" >> ~/system_reports.log
free -h >> ~/system_reports.log
echo "=================================" >> ~/system_reports.log
echo "" >> ~/system_reports.log
EOF
chmod +x ~/scripts/system_info.sh
~/scripts/system_info.sh || true
tail -n +1 ~/system_reports.log || true
pause "Open crontab editor to add every-5-min job:\n  */5 * * * * /home/$(whoami)/scripts/system_info.sh"

# ----- Task 1.4: More cron jobs
info "Create daily_backup.sh"
cat > ~/scripts/daily_backup.sh << 'EOF'
#!/bin/bash
# Daily Backup Script
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/home_backup_$DATE.tar.gz ~/scripts ~/system_reports.log 2>/dev/null
find $BACKUP_DIR -name "home_backup_*.tar.gz" -mtime +7 -delete
echo "Backup completed at $(date)" >> ~/backup.log
EOF
chmod +x ~/scripts/daily_backup.sh
pause "Add to crontab:\n# System info every 5 minutes\n*/5 * * * * /home/$(whoami)/scripts/system_info.sh\n\n# Daily backup at 2:30 AM\n30 2 * * * /home/$(whoami)/scripts/daily_backup.sh\n\n# Weekly cleanup on Sundays at 3:00 AM\n0 3 * * 0 find /tmp -name \"*.tmp\" -mtime +7 -delete"

# ----- Task 1.5: Logging cron job
info "Create log_monitor.sh"
cat > ~/scripts/log_monitor.sh << 'EOF'
#!/bin/bash
# Log Monitor Script with proper logging
LOG_FILE=~/cron_monitor.log
{
    echo "=== Log Monitor Started at $(date) ==="
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "Current system load: $LOAD"
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Root disk usage: $DISK_USAGE%"
    if [ "$DISK_USAGE" -gt 80 ] 2>/dev/null; then
        echo "WARNING: Disk usage is above 80%"
    fi
    echo "=== Log Monitor Completed at $(date) ==="
    echo ""
} >> "$LOG_FILE" 2>&1
EOF
chmod +x ~/scripts/log_monitor.sh
pause "Add to crontab:\n# Log monitor every 10 minutes\n*/10 * * * * /home/$(whoami)/scripts/log_monitor.sh"

# ----- Task 2.1: systemd timers overview
systemctl list-timers || true
systemctl status *.timer || true
ls -la /etc/systemd/system/*.timer 2>/dev/null || true
ls -la /usr/lib/systemd/system/*.timer 2>/dev/null || true

# ----- Task 2.2: system-status service & timer
info "Create system-status.service and script"
sudo tee /etc/systemd/system/system-status.service >/dev/null << 'EOF'
[Unit]
Description=System Status Reporter
Wants=system-status.timer

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/system-status.sh

[Install]
WantedBy=multi-user.target
EOF
sudo tee /usr/local/bin/system-status.sh >/dev/null << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/system-status.log"
{
    echo "=== System Status Report - $(date) ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Load Average: $(cat /proc/loadavg)"
    echo "Memory Info:"
    free -h
    echo "Top 5 Processes by CPU:"
    ps aux --sort=-%cpu | head -6
    echo "================================="
    echo ""
} >> "$LOG_FILE"
EOF
sudo chmod +x /usr/local/bin/system-status.sh
sudo tee /etc/systemd/system/system-status.timer >/dev/null << 'EOF'
[Unit]
Description=Run system-status.service every 15 minutes
Requires=system-status.service

[Timer]
OnCalendar=*:0/15
Persistent=true

[Install]
WantedBy=timers.target
EOF

# ----- Task 2.3: manage timer
sudo systemctl daemon-reload
sudo systemctl enable system-status.timer
sudo systemctl start system-status.timer
sudo systemctl status system-status.timer || true
systemctl list-timers --all || true
systemctl list-timers system-status.timer || true

# ----- Task 2.4: advanced timer (temp cleanup)
info "Create temp-cleanup service/timer and script"
sudo tee /etc/systemd/system/temp-cleanup.service >/dev/null << 'EOF'
[Unit]
Description=Temporary Files Cleanup Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/temp-cleanup.sh
User=root
EOF
sudo tee /usr/local/bin/temp-cleanup.sh >/dev/null << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/temp-cleanup.log"
{
    echo "=== Temp Cleanup Started - $(date) ==="
    DELETED_COUNT=$(find /tmp -type f -mtime +7 -delete -print | wc -l)
    echo "Deleted $DELETED_COUNT files from /tmp"
    find /var/log -name "*.log" -mtime +30 -size +100M -exec truncate -s 0 {} \;
    echo "Truncated large old log files"
    if command -v dnf &> /dev/null; then
        dnf clean packages -q
        echo "Cleaned DNF package cache"
    elif command -v yum &> /dev/null; then
        yum clean packages -q
        echo "Cleaned YUM package cache"
    fi
    echo "=== Temp Cleanup Completed - $(date) ==="
    echo ""
} >> "$LOG_FILE" 2>&1
EOF
sudo chmod +x /usr/local/bin/temp-cleanup.sh
sudo tee /etc/systemd/system/temp-cleanup.timer >/dev/null << 'EOF'
[Unit]
Description=Weekly temporary files cleanup
Requires=temp-cleanup.service

[Timer]
OnCalendar=weekly
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable temp-cleanup.timer
sudo systemctl start temp-cleanup.timer
sudo systemctl status temp-cleanup.timer || true

# ----- Task 2.5: user-level timers
info "User-level personal-backup timer"
mkdir -p ~/.config/systemd/user
tee ~/.config/systemd/user/personal-backup.service >/dev/null << 'EOF'
[Unit]
Description=Personal Backup Service

[Service]
Type=oneshot
ExecStart=%h/scripts/personal-backup.sh
EOF
cat > ~/scripts/personal-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/personal_backup_$DATE.tar.gz" ~/scripts ~/Documents 2>/dev/null
ls -t "$BACKUP_DIR"/personal_backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
echo "Personal backup completed at $(date)" >> ~/personal_backup.log
EOF
chmod +x ~/scripts/personal-backup.sh
tee ~/.config/systemd/user/personal-backup.timer >/dev/null << 'EOF'
[Unit]
Description=Daily personal backup
Requires=personal-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl --user daemon-reload || true
systemctl --user enable personal-backup.timer || true
systemctl --user start personal-backup.timer || true
systemctl --user list-timers || true

# ----- Task 3 helpers
sudo journalctl -u crond -n 10 --no-pager || true
sudo tail -n 20 /var/log/cron || true
~/scripts/system_info.sh || true
ls -la ~/system_reports.log || true
tail -n 10 ~/system_reports.log || true

cat > ~/scripts/env_test.sh << 'EOF'
#!/bin/bash
{
    echo "=== Environment Test - $(date) ==="
    echo "PATH: $PATH"
    echo "HOME: $HOME"
    echo "USER: $USER"
    echo "PWD: $PWD"
    echo "Shell: $SHELL"
    echo "=== End Environment Test ==="
    echo ""
} >> ~/env_test.log
EOF
chmod +x ~/scripts/env_test.sh

cat > ~/scripts/debug_cron.sh << 'EOF'
#!/bin/bash
DEBUG_LOG=~/cron_debug.log
{
    echo "=== Cron Debug Session - $(date) ==="
    echo "Script executed from: $PWD"
    echo "Script path: $0"
    echo "Arguments: $@"
    echo "Environment variables:"
    env | sort
    echo "=== End Debug Session ==="
    echo ""
} >> "$DEBUG_LOG" 2>&1
EOF
chmod +x ~/scripts/debug_cron.sh

sudo tee /usr/local/bin/debug-systemd.sh >/dev/null << 'EOF'
#!/bin/bash
DEBUG_LOG="/var/log/systemd-debug.log"
{
    echo "=== systemd Debug Session - $(date) ==="
    echo "Service: $1"
    echo "Working directory: $PWD"
    echo "User: $(whoami)"
    echo "Groups: $(groups)"
    echo "Environment:"
    env | sort
    echo "=== End systemd Debug Session ==="
    echo ""
} >> "$DEBUG_LOG" 2>&1
EOF
sudo chmod +x /usr/local/bin/debug-systemd.sh

cat > ~/scripts/monitor_automation.sh << 'EOF'
#!/bin/bash
REPORT_FILE=~/automation_report.log
{
    echo "=== Automation Status Report - $(date) ==="
    echo "--- Cron Jobs Status ---"
    echo "Active crontab entries:"
    crontab -l | grep -v '^#' | grep -v '^$' | wc -l
    echo "Recent cron executions:"
    sudo grep "$(whoami)" /var/log/cron | tail -5
    echo "--- systemd Timers Status ---"
    echo "Active timers:"
    systemctl list-timers --no-pager | grep -c "timer"
    echo "Recent timer executions:"
    sudo journalctl -u "*.timer" --since "1 hour ago" --no-pager | tail -5
    echo "--- Log File Sizes ---"
    ls -lh ~/system_reports.log ~/cron_monitor.log ~/backup.log 2>/dev/null
    echo "=== End Automation Report ==="
    echo ""
} >> "$REPORT_FILE" 2>&1
EOF
chmod +x ~/scripts/monitor_automation.sh
~/scripts/monitor_automation.sh || true
tail -n 50 ~/automation_report.log || true

echo "Lab 12 script complete. Follow manual crontab -e steps where prompted."
