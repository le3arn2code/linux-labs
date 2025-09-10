#!/usr/bin/env bash
# Lab 15 — Managing SELinux Policies (RHEL/CentOS/Fedora)
# EXACT lab steps. Some steps intentionally produce denials; we capture them.
set -euo pipefail

info(){ printf "\n==> %s\n" "$*"; }

# ----- Task 1
info "Verify sudo/root and SELinux status"
sudo whoami || true
sestatus || true
getenforce || true
cat /etc/selinux/config || true
ls -Z ~/ || true
ps -eZ | head -10 || true
id -Z || true

# ----- Task 2.1
info "Install SELinux management tools"
sudo dnf install -y policycoreutils-python-utils setools-console || true
which semanage || true
semanage --help >/dev/null 2>&1 || true

# ----- Task 2.2 file contexts
info "Create test dir and set context"
mkdir -p /opt/testapp || true
sudo touch /opt/testapp/config.conf || true
ls -Z /opt/testapp/ || true
sudo semanage fcontext -a -t httpd_config_t "/opt/testapp/config.conf" || true
sudo restorecon -v /opt/testapp/config.conf || true
ls -Z /opt/testapp/config.conf || true

# ----- Task 2.3 port contexts
info "HTTP port contexts; add 8080"
semanage port -l | grep http || true
sudo semanage port -a -t http_port_t -p tcp 8080 || true
semanage port -l | grep 8080 || true

# ----- Task 2.4 booleans
info "SELinux booleans"
getsebool -a | head -10 || true
getsebool httpd_can_network_connect || true
sudo setsebool httpd_can_network_connect on || true
sudo setsebool -P httpd_can_network_connect on || true
getsebool httpd_can_network_connect || true

# ----- Task 2.5 user mappings
info "SELinux user mappings"
semanage login -l || true
semanage user -l || true

# ----- Task 3.1 audit logs
info "Install setroubleshoot-server and check auditd"
sudo dnf install -y setroubleshoot-server || true
sudo systemctl status auditd || true
sudo ausearch -m avc -ts recent || true

# ----- Task 3.2 create denials with httpd
info "Create website in /home/testuser/website (may trigger denials)"
sudo mkdir -p /home/testuser/website || true
# NOTE: this line often fails due to redirection without sudo; we keep it to match the lab
sudo echo "<html><body>Test Page</body></html>" > /home/testuser/website/index.html || true
# Corrective write to ensure file exists for subsequent steps
echo "<html><body>Test Page</body></html>" | sudo tee /home/testuser/website/index.html >/dev/null
sudo chown -R apache:apache /home/testuser/website || true

info "Install and start Apache"
sudo dnf install -y httpd || true
sudo systemctl start httpd || true
sudo systemctl enable httpd || true

info "Configure Apache vhost"
sudo tee /etc/httpd/conf.d/testsite.conf << 'EOF' >/dev/null
<VirtualHost *:80>
    DocumentRoot /home/testuser/website
    <Directory "/home/testuser/website">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

info "Restart Apache (expect SELinux denials)"
sudo systemctl restart httpd || true
curl -fsS http://localhost/ || true

# ----- Task 3.3 analyze denials
info "Analyze SELinux denials"
sudo ausearch -m avc -ts recent || true
sudo sealert -a /var/log/audit/audit.log || true
sudo grep "denied" /var/log/audit/audit.log | tail -5 || true

# ----- Task 3.4 resolve denials per lab (types may still be restrictive)
info "Apply contexts per lab, then test again"
ls -Z /home/testuser/website/ || true
sudo semanage fcontext -a -t httpd_exec_t "/home/testuser/website(/.*)?" || true
sudo restorecon -R -v /home/testuser/website/ || true
sudo chcon --reference=/var/www/html /home/testuser/website/index.html || true
ls -Z /home/testuser/website/ || true
curl -fsS http://localhost/ || true

# ----- Task 3.5 policy module
info "Generate and install policy module if needed"
sudo grep httpd /var/log/audit/audit.log | audit2allow -M myhttpd || true
cat myhttpd.te || true
sudo semodule -i myhttpd.pp || true

# ----- Advanced mgmt
info "Modules, versions, monitoring"
semodule -l | head -10 || true
semodule -l | grep httpd || true
sestatus | grep "policy version" || true

sudo tee /usr/local/bin/selinux-monitor.sh << 'EOF' >/dev/null
#!/bin/bash
echo "=== SELinux Status ==="
sestatus

echo -e "\n=== Recent SELinux Denials ==="
ausearch -m avc -ts today 2>/dev/null | tail -10

echo -e "\n=== SELinux Boolean Status ==="
getsebool -a | grep "on$" | wc -l
echo "Total booleans enabled"

echo -e "\n=== Custom File Contexts ==="
semanage fcontext -l -C
EOF
sudo chmod +x /usr/local/bin/selinux-monitor.sh || true
sudo /usr/local/bin/selinux-monitor.sh || true
echo "0 */6 * * * root /usr/local/bin/selinux-monitor.sh >> /var/log/selinux-monitor.log 2>&1" | sudo tee -a /etc/crontab >/dev/null

# ----- Cleanup (optional, as per lab)
info "Cleanup test artifacts"
sudo rm -rf /opt/testapp || true
sudo rm -rf /home/testuser/website || true
sudo rm -f /etc/httpd/conf.d/testsite.conf || true
sudo semanage fcontext -d "/opt/testapp/config.conf" || true
sudo semanage port -d -t http_port_t -p tcp 8080 || true
sudo systemctl restart httpd || true

echo "Lab 15 script complete."
