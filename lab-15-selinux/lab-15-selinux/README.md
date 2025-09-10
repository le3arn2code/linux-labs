# Lab 15 — Managing SELinux Policies (RHEL/CentOS/Fedora)

> **Environment:** Al‑Nafi cloud VM • **OS:** RHEL 9 / CentOS Stream 9 (SELinux enabled) • **Access:** root/sudo • **Tools:** `sestatus`, `semanage`, `restorecon`, `ausearch`, `sealert`, `audit2allow`

## Objectives
- Understand SELinux concepts & security model
- Check & interpret SELinux status with `sestatus`
- Modify SELinux policies via `semanage`
- Troubleshoot denials with audit logs
- Apply SELinux best practices (contexts, booleans)
- Configure contexts & boolean settings for specific apps

## Prerequisites
- Linux CLI, permissions/ownership basics
- Log analysis familiarity
- RHEL/CentOS/Fedora with sudo

## Lab Environment Setup
- RHEL 9 / CentOS Stream 9
- SELinux **enabled** (targeted policy)
- SELinux management tools pre-installed (you will verify below)
- Sample app/services for testing

---

## Task 1: Check SELinux Status with `sestatus`

### Subtask 1.1: Understanding SELinux Basics
**Step 1:** Verify sudo/root
```bash
sudo whoami
```
**Step 2:** Comprehensive SELinux status
```bash
sestatus
```
*Expected Output (example snippet):*
```
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

### Subtask 1.2: Understanding SELinux Modes
**Step 3:** Current mode
```bash
getenforce
```
**Step 4:** Mode from config file
```bash
cat /etc/selinux/config
```
**Key Concepts**
- **Enforcing:** Policy enforced; denials logged & blocked
- **Permissive:** Policy not enforced; denials **logged**
- **Disabled:** SELinux off

### Subtask 1.3: Examining SELinux Contexts
**Step 5:** File contexts in home
```bash
ls -Z ~/
```
**Step 6:** Process contexts
```bash
ps -eZ | head -10
```
**Step 7:** Current user context
```bash
id -Z
```

---

## Task 2: Modify SELinux Policies with `semanage`

### Subtask 2.1: Installing SELinux Management Tools
**Step 8:** Ensure tools are present
```bash
sudo dnf install -y policycoreutils-python-utils setools-console
```
**Step 9:** Verify `semanage`
```bash
which semanage
semanage --help
```

### Subtask 2.2: Managing SELinux File Contexts
**Step 10:** Create test dir/file
```bash
mkdir -p /opt/testapp
sudo touch /opt/testapp/config.conf
```
**Step 11:** Check current context
```bash
ls -Z /opt/testapp/
```
**Step 12:** Add custom file context rule
```bash
sudo semanage fcontext -a -t httpd_config_t "/opt/testapp/config.conf"
```
**Step 13:** Apply new context
```bash
sudo restorecon -v /opt/testapp/config.conf
```
**Step 14:** Verify context change
```bash
ls -Z /opt/testapp/config.conf
```

### Subtask 2.3: Managing SELinux Port Contexts
**Step 15:** View HTTP port contexts
```bash
semanage port -l | grep http
```
**Step 16:** Add custom HTTP port (8080)
```bash
sudo semanage port -a -t http_port_t -p tcp 8080
```
**Step 17:** Verify new port context
```bash
semanage port -l | grep 8080
```

### Subtask 2.4: Managing SELinux Booleans
**Step 18:** List booleans
```bash
getsebool -a | head -10
```
**Step 19:** Check specific boolean
```bash
getsebool httpd_can_network_connect
```
**Step 20:** Temporarily enable
```bash
sudo setsebool httpd_can_network_connect on
```
**Step 21:** Persist change
```bash
sudo setsebool -P httpd_can_network_connect on
```
**Step 22:** Verify
```bash
getsebool httpd_can_network_connect
```

### Subtask 2.5: Managing SELinux User Mappings
**Step 23:** SELinux login mappings
```bash
semanage login -l
```
**Step 24:** SELinux users
```bash
semanage user -l
```

---

## Task 3: Troubleshoot SELinux Denials Using Audit Logs

### Subtask 3.1: Understanding SELinux Audit Logs
**Step 25:** Install troubleshooting server
```bash
sudo dnf install -y setroubleshoot-server
```
**Step 26:** Check `auditd`
```bash
sudo systemctl status auditd
```
**Step 27:** View recent denials
```bash
sudo ausearch -m avc -ts recent
```

### Subtask 3.2: Creating & Analyzing SELinux Denials
**Step 28:** Create web content (intentionally non‑standard location)
```bash
sudo mkdir -p /home/testuser/website
sudo echo "<html><body>Test Page</body></html>" > /home/testuser/website/index.html
sudo chown -R apache:apache /home/testuser/website
```
**Step 29:** Install & start Apache
```bash
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
```
**Step 30:** Configure Apache to use that path
```bash
sudo tee /etc/httpd/conf.d/testsite.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /home/testuser/website
    <Directory "/home/testuser/website">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF
```
**Step 31:** Restart Apache (expect SELinux denials)
```bash
sudo systemctl restart httpd
```
**Step 32:** Access the site
```bash
curl http://localhost/
```

### Subtask 3.3: Analyzing SELinux Denials
**Step 33:** Check denials again
```bash
sudo ausearch -m avc -ts recent
```
**Step 34:** Analyze with `sealert`
```bash
sudo sealert -a /var/log/audit/audit.log
```
**Step 35:** Quick grep for denied lines
```bash
sudo grep "denied" /var/log/audit/audit.log | tail -5
```

### Subtask 3.4: Resolving Denials
**Step 36:** Inspect current contexts
```bash
ls -Z /home/testuser/website/
```
**Step 37:** Set SELinux context for web content (per lab)
```bash
sudo semanage fcontext -a -t httpd_exec_t "/home/testuser/website(/.*)?"
sudo restorecon -R -v /home/testuser/website/
```
**Step 38:** Alternative approach — copy context from default web root
```bash
sudo chcon --reference=/var/www/html /home/testuser/website/index.html
```
**Step 39:** Verify context change
```bash
ls -Z /home/testuser/website/
```
**Step 40:** Test site again
```bash
curl http://localhost/
```

### Subtask 3.5: SELinux Troubleshooting Tools
**Step 41:** (Optional GUI tools)
```bash
sudo dnf install -y policycoreutils-gui
```
**Step 42:** Generate a custom policy module
```bash
sudo grep httpd /var/log/audit/audit.log | audit2allow -M myhttpd
```
**Step 43:** Review generated policy
```bash
cat myhttpd.te
```
**Step 44:** Install custom policy (only if necessary)
```bash
sudo semodule -i myhttpd.pp
```

---

## Advanced SELinux Management

### Subtask 3.6: Policy Modules
**Step 45:** List installed modules
```bash
semodule -l | head -10
```
**Step 46:** Info about httpd module
```bash
semodule -l | grep httpd
```
**Step 47:** Policy version
```bash
sestatus | grep "policy version"
```

### Subtask 3.7: Monitoring & Maintenance
**Step 48:** Monitoring script
```bash
sudo tee /usr/local/bin/selinux-monitor.sh << 'EOF'
#!/bin/bash
echo "=== SELinux Status ==="
sestatus

echo -e "
=== Recent SELinux Denials ==="
ausearch -m avc -ts today 2>/dev/null | tail -10

echo -e "
=== SELinux Boolean Status ==="
getsebool -a | grep "on$" | wc -l
echo "Total booleans enabled"

echo -e "
=== Custom File Contexts ==="
semanage fcontext -l -C
EOF
sudo chmod +x /usr/local/bin/selinux-monitor.sh
```
**Step 49:** Run it
```bash
sudo /usr/local/bin/selinux-monitor.sh
```
**Step 50:** Cron for regular monitoring
```bash
echo "0 */6 * * * root /usr/local/bin/selinux-monitor.sh >> /var/log/selinux-monitor.log 2>&1" | sudo tee -a /etc/crontab
```

---

## Troubleshooting Common Issues
- Service fails to start: check audit logs; adjust file contexts/booleans
- Web server cannot access non‑standard paths: set appropriate contexts (see steps 37–39)
- App cannot bind to non‑standard port: add port context via `semanage port`

**Debugging commands**
```bash
sudo ausearch -m avc -ts recent
sudo sealert -a /var/log/audit/audit.log
sudo grep denied /var/log/audit/audit.log | audit2allow
```

---

## Lab Cleanup
**Step 51:** Remove test artifacts
```bash
sudo rm -rf /opt/testapp
sudo rm -rf /home/testuser/website
sudo rm -f /etc/httpd/conf.d/testsite.conf
sudo semanage fcontext -d "/opt/testapp/config.conf"
sudo semanage port -d -t http_port_t -p tcp 8080
sudo systemctl restart httpd
```

## Conclusion
You checked SELinux status, edited policy with `semanage`, analyzed denials, and applied remediations—skills essential for hardening and troubleshooting SELinux‑enabled systems.
