# Lab 12 — Automating Tasks with Cron and systemd Timers (CentOS/RHEL 8/9)

> **Environment:** Al‑Nafi cloud VM • **Init:** systemd • **Access:** root/sudo

## Objectives
- Understand the differences between **cron** and **systemd timers** for task automation
- Create and configure cron jobs using crontab syntax
- Set up systemd timers and service units for scheduled tasks
- Test and verify automated tasks are running correctly
- Debug common issues with scheduled tasks
- Monitor and manage automated jobs effectively
- Apply best practices for task automation in Linux environments

## Prerequisites
- Basic Linux command‑line knowledge
- Understanding of file permissions and ownership
- Familiarity with text editors (nano, vim)
- Basic shell scripting
- Understanding of services/processes
- Root or sudo privileges

## Lab Environment
- CentOS/RHEL 8 or 9 with **crond** and **systemd** installed
- Text editors and basic utilities
- Sample scripts and log directories

---

## Task 1: Understanding and Creating Cron Jobs

### Subtask 1.1: Exploring the Cron System
1. Check if cron service is running:
```bash
sudo systemctl status crond
```
2. If cron is not running, start and enable it:
```bash
sudo systemctl start crond
sudo systemctl enable crond
```
3. View current user's crontab:
```bash
crontab -l
```
4. Check system‑wide cron directories:
```bash
ls -la /etc/cron*
```
5. Examine the main cron configuration:
```bash
cat /etc/crontab
```

### Subtask 1.2: Understanding Cron Syntax
```
* * * * *  command
│ │ │ │ │
│ │ │ │ └── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```
Common examples:
- `0 2 * * *` — Run at 2:00 AM every day
- `*/15 * * * *` — Run every 15 minutes
- `0 9 * * 1-5` — Run at 9:00 AM Monday–Friday
- `30 14 1 * *` — Run at 2:30 PM on the 1st of each month

### Subtask 1.3: Creating Your First Cron Job
1. Create a simple script to automate:
```bash
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
```
2. Make the script executable:
```bash
chmod +x ~/scripts/system_info.sh
```
3. Test the script manually:
```bash
~/scripts/system_info.sh
cat ~/system_reports.log
```
4. Open crontab for editing:
```bash
crontab -e
```
5. Add a cron job to run every 5 minutes:
```
*/5 * * * * /home/$(whoami)/scripts/system_info.sh
```
6. Save/exit and verify:
```bash
crontab -l
```

### Subtask 1.4: Creating More Complex Cron Jobs
1. Create a backup script:
```bash
cat > ~/scripts/daily_backup.sh << 'EOF'
#!/bin/bash
# Daily Backup Script
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Backup important directories
tar -czf $BACKUP_DIR/home_backup_$DATE.tar.gz ~/scripts ~/system_reports.log 2>/dev/null

# Keep only last 7 days of backups
find $BACKUP_DIR -name "home_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed at $(date)" >> ~/backup.log
EOF
```
2. Make it executable:
```bash
chmod +x ~/scripts/daily_backup.sh
```
3. Add multiple cron jobs:
```bash
crontab -e
```
Add these lines:
```
# System info every 5 minutes
*/5 * * * * /home/$(whoami)/scripts/system_info.sh

# Daily backup at 2:30 AM
30 2 * * * /home/$(whoami)/scripts/daily_backup.sh

# Weekly cleanup on Sundays at 3:00 AM
0 3 * * 0 find /tmp -name "*.tmp" -mtime +7 -delete
```

### Subtask 1.5: Managing Cron Jobs with Logging
1. Create a script with proper logging:
```bash
cat > ~/scripts/log_monitor.sh << 'EOF'
#!/bin/bash
# Log Monitor Script with proper logging
LOG_FILE=~/cron_monitor.log

{
    echo "=== Log Monitor Started at $(date) ==="
    
    # Check system load
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "Current system load: $LOAD"
    
    # Check disk space
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Root disk usage: $DISK_USAGE%"
    
    if [ $DISK_USAGE -gt 80 ]; then
        echo "WARNING: Disk usage is above 80%"
    fi
    
    echo "=== Log Monitor Completed at $(date) ==="
    echo ""
} >> $LOG_FILE 2>&1
EOF
```
2. Make it executable:
```bash
chmod +x ~/scripts/log_monitor.sh
```
3. Update crontab with logging:
```bash
crontab -e
```
Add:
```
# Log monitor every 10 minutes
*/10 * * * * /home/$(whoami)/scripts/log_monitor.sh
```

---

## Task 2: Setting Up systemd Timers

### Subtask 2.1: Understanding systemd Timers
1. Check existing timers:
```bash
systemctl list-timers
```
2. View timer status:
```bash
systemctl status *.timer
```
3. Explore timer directories:
```bash
ls -la /etc/systemd/system/*.timer
ls -la /usr/lib/systemd/system/*.timer
```

### Subtask 2.2: Creating Your First systemd Timer
1. Create a service unit file:
```bash
sudo tee /etc/systemd/system/system-status.service << 'EOF'
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
```
2. Create the script:
```bash
sudo tee /usr/local/bin/system-status.sh << 'EOF'
#!/bin/bash
# System Status Script for systemd
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
} >> $LOG_FILE
EOF
```
3. Make the script executable:
```bash
sudo chmod +x /usr/local/bin/system-status.sh
```
4. Create the timer unit:
```bash
sudo tee /etc/systemd/system/system-status.timer << 'EOF'
[Unit]
Description=Run system-status.service every 15 minutes
Requires=system-status.service

[Timer]
OnCalendar=*:0/15
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

### Subtask 2.3: Managing systemd Timers
1. Reload configuration:
```bash
sudo systemctl daemon-reload
```
2. Enable/start the timer:
```bash
sudo systemctl enable system-status.timer
sudo systemctl start system-status.timer
```
3. Check timer status:
```bash
sudo systemctl status system-status.timer
```
4. List timers:
```bash
systemctl list-timers --all
```
5. View the next run:
```bash
systemctl list-timers system-status.timer
```

### Subtask 2.4: Creating Advanced systemd Timers
1. Create a cleanup service:
```bash
sudo tee /etc/systemd/system/temp-cleanup.service << 'EOF'
[Unit]
Description=Temporary Files Cleanup Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/temp-cleanup.sh
User=root
EOF
```
2. Create the cleanup script:
```bash
sudo tee /usr/local/bin/temp-cleanup.sh << 'EOF'
#!/bin/bash
# Temporary Files Cleanup Script
LOG_FILE="/var/log/temp-cleanup.log"

{
    echo "=== Temp Cleanup Started - $(date) ==="
    
    # Clean /tmp files older than 7 days
    DELETED_COUNT=$(find /tmp -type f -mtime +7 -delete -print | wc -l)
    echo "Deleted $DELETED_COUNT files from /tmp"
    
    # Clean log files older than 30 days
    find /var/log -name "*.log" -mtime +30 -size +100M -exec truncate -s 0 {} \;
    echo "Truncated large old log files"
    
    # Clean package cache
    if command -v dnf &> /dev/null; then
        dnf clean packages -q
        echo "Cleaned DNF package cache"
    elif command -v yum &> /dev/null; then
        yum clean packages -q
        echo "Cleaned YUM package cache"
    fi
    
    echo "=== Temp Cleanup Completed - $(date) ==="
    echo ""
} >> $LOG_FILE 2>&1
EOF
```
3. Make it executable:
```bash
sudo chmod +x /usr/local/bin/temp-cleanup.sh
```
4. Create a weekly timer:
```bash
sudo tee /etc/systemd/system/temp-cleanup.timer << 'EOF'
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
```
5. Enable and start the weekly cleanup timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable temp-cleanup.timer
sudo systemctl start temp-cleanup.timer
```

### Subtask 2.5: Creating User‑Level systemd Timers
1. Create user systemd directory:
```bash
mkdir -p ~/.config/systemd/user
```
2. Create a user service:
```bash
tee ~/.config/systemd/user/personal-backup.service << 'EOF'
[Unit]
Description=Personal Backup Service

[Service]
Type=oneshot
ExecStart=%h/scripts/personal-backup.sh
EOF
```
3. Personal backup script:
```bash
cat > ~/scripts/personal-backup.sh << 'EOF'
#!/bin/bash
# Personal Backup Script
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup documents and scripts
tar -czf $BACKUP_DIR/personal_backup_$DATE.tar.gz ~/scripts ~/Documents 2>/dev/null

# Keep only last 5 backups
ls -t $BACKUP_DIR/personal_backup_*.tar.gz | tail -n +6 | xargs -r rm

echo "Personal backup completed at $(date)" >> ~/personal_backup.log
EOF
```
4. Make it executable:
```bash
chmod +x ~/scripts/personal-backup.sh
```
5. Create a user timer:
```bash
tee ~/.config/systemd/user/personal-backup.timer << 'EOF'
[Unit]
Description=Daily personal backup
Requires=personal-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF
```
6. Enable user timers:
```bash
systemctl --user daemon-reload
systemctl --user enable personal-backup.timer
systemctl --user start personal-backup.timer
```
7. Check user timers:
```bash
systemctl --user list-timers
```

---

## Task 3: Testing and Debugging Cron and systemd Jobs

### Subtask 3.1: Testing Cron Jobs
1. Check cron service logs:
```bash
sudo journalctl -u crond -f
```
2. Monitor cron in real‑time:
```bash
sudo tail -f /var/log/cron
```
3. Test a cron job manually:
```bash
~/scripts/system_info.sh
ls -la ~/system_reports.log
tail ~/system_reports.log
```
4. Create a test cron job that runs every minute:
```bash
crontab -e
```
Add:
```
# Test job - runs every minute
* * * * * echo "Test cron job executed at $(date)" >> ~/cron_test.log
```
5. Wait a few minutes and check results:
```bash
tail -f ~/cron_test.log
```
6. Remove the test job:
```bash
crontab -e
# Remove or comment the test line
```

### Subtask 3.2: Debugging Common Cron Issues
1. Check for common problems:
```bash
sudo systemctl status crond
sudo grep CRON /var/log/messages
sudo journalctl -u crond --since "1 hour ago"
```
2. Create a script to test environment variables:
```bash
cat > ~/scripts/env_test.sh << 'EOF'
#!/bin/bash
# Environment Test Script
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
```
3. Make it executable and add to cron:
```bash
chmod +x ~/scripts/env_test.sh
crontab -e
```
Add:
```
# Environment test
*/2 * * * * /home/$(whoami)/scripts/env_test.sh
```
4. Check the environment output:
```bash
tail ~/env_test.log
```

### Subtask 3.3: Testing systemd Timers
1. Check systemd timer logs:
```bash
sudo journalctl -u system-status.timer -f
```
2. View service execution logs:
```bash
sudo journalctl -u system-status.service --since "1 hour ago"
```
3. Manually trigger a service:
```bash
sudo systemctl start system-status.service
```
4. Check service output:
```bash
sudo tail /var/log/system-status.log
```
5. Test timer accuracy:
```bash
systemctl list-timers system-status.timer
sudo systemctl status system-status.timer
```

### Subtask 3.4: Advanced Debugging Techniques
1. Cron debugging script:
```bash
cat > ~/scripts/debug_cron.sh << 'EOF'
#!/bin/bash
# Cron Debug Script
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
} >> $DEBUG_LOG 2>&1
EOF
```
2. Make it executable and test:
```bash
chmod +x ~/scripts/debug_cron.sh
crontab -e
```
Add:
```
# Debug cron job
*/3 * * * * /home/$(whoami)/scripts/debug_cron.sh arg1 arg2
```
3. Monitor debug output:
```bash
tail -f ~/cron_debug.log
```
4. systemd debugging script:
```bash
sudo tee /usr/local/bin/debug-systemd.sh << 'EOF'
#!/bin/bash
# systemd Debug Script
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
} >> $DEBUG_LOG 2>&1
EOF
```
5. Make it executable:
```bash
sudo chmod +x /usr/local/bin/debug-systemd.sh
```

### Subtask 3.5: Monitoring and Maintenance
1. Create a monitoring script:
```bash
cat > ~/scripts/monitor_automation.sh << 'EOF'
#!/bin/bash
# Automation Monitor Script
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
} >> $REPORT_FILE 2>&1
EOF
```
2. Make executable:
```bash
chmod +x ~/scripts/monitor_automation.sh
```
3. Run and view:
```bash
~/scripts/monitor_automation.sh
cat ~/automation_report.log
```
4. Clean up test cron jobs:
```bash
crontab -e
# Remove test entries you no longer need
```

---

## Verification
- `systemctl status crond`
- `crontab -l`
- `systemctl list-timers --all`
- `sudo journalctl -u *.timer -n 20`
- `sudo tail /var/log/system-status.log`
- `sudo tail /var/log/temp-cleanup.log`
