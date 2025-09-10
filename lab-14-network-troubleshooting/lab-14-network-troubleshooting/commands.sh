#!/usr/bin/env bash
# Lab 14 — Troubleshooting Network Connectivity (RHEL/CentOS)
# EXACT lab steps. Some commands may require packages; installs are included where specified.
set -euo pipefail

info(){ printf "\n==> %s\n" "$*"; }

# ----- Task 1.1: ping tests
info "Local ping"
ping -c 4 127.0.0.1 || true

info "Gateway ping"
ip route show default || true
# Replace the IP below if different
ping -c 4 192.168.1.1 || true

info "External ping (IP and DNS)"
ping -c 4 8.8.8.8 || true
ping -c 4 google.com || true

# ----- Task 1.2: traceroute
info "Install traceroute if needed"
if command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y traceroute || true
else
  sudo yum install -y traceroute || true
fi

info "Traceroute tests"
traceroute google.com || true
traceroute -n 8.8.8.8 || true

# ----- Task 1.3: nslookup
info "nslookup tests"
nslookup google.com || true
nslookup 8.8.8.8 || true
nslookup -type=MX google.com || true
nslookup -type=NS google.com || true
nslookup google.com 8.8.8.8 || true

# ----- Task 2.1: nmcli view
info "nmcli general/device status"
nmcli general status || true
nmcli device status || true
nmcli device show || true

# ----- Task 2.2: nmcli connections
info "List connections and active ones"
nmcli connection show || true
nmcli connection show --active || true
nmcli connection show "System eth0" || true

# ----- Task 2.3: modify settings
info "Modify DNS on System eth0"
sudo nmcli connection modify "System eth0" ipv4.dns "8.8.8.8,8.8.4.4" || true
sudo nmcli connection up "System eth0" || true

info "Set static IP then revert to DHCP"
sudo nmcli connection modify "System eth0" ipv4.addresses "192.168.1.100/24" || true
sudo nmcli connection modify "System eth0" ipv4.gateway "192.168.1.1" || true
sudo nmcli connection modify "System eth0" ipv4.method manual || true
sudo nmcli connection up "System eth0" || true
sudo nmcli connection modify "System eth0" ipv4.method auto || true
sudo nmcli connection up "System eth0" || true

# ----- Task 2.4: create new connection
info "Create and activate lab-connection"
sudo nmcli connection add type ethernet con-name "lab-connection" ifname eth0 || true
sudo nmcli connection modify "lab-connection" ipv4.addresses "192.168.1.150/24" || true
sudo nmcli connection modify "lab-connection" ipv4.gateway "192.168.1.1" || true
sudo nmcli connection modify "lab-connection" ipv4.dns "8.8.8.8" || true
sudo nmcli connection modify "lab-connection" ipv4.method manual || true
sudo nmcli connection up "lab-connection" || true

# ----- Task 3.1: firewalld basics
info "firewalld status and enable if needed"
sudo systemctl status firewalld || true
sudo systemctl start firewalld || true
sudo systemctl enable firewalld || true

info "firewalld zones"
sudo firewall-cmd --get-default-zone || true
sudo firewall-cmd --get-zones || true
sudo firewall-cmd --get-active-zones || true
sudo firewall-cmd --list-all || true
sudo firewall-cmd --zone=public --list-all || true

# ----- Task 3.2: services
info "firewalld services"
sudo firewall-cmd --get-services || true
sudo firewall-cmd --zone=public --add-service=http --permanent || true
sudo firewall-cmd --zone=public --add-service=https --permanent || true
sudo firewall-cmd --zone=public --add-service=ssh --permanent || true
sudo firewall-cmd --reload || true
sudo firewall-cmd --zone=public --list-services || true

# ----- Task 3.3: ports
info "Open ports and verify"
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent || true
sudo firewall-cmd --zone=public --add-port=53/udp --permanent || true
sudo firewall-cmd --zone=public --add-port=3000-3005/tcp --permanent || true
sudo firewall-cmd --reload || true
sudo firewall-cmd --zone=public --list-ports || true
sudo firewall-cmd --zone=public --remove-port=8080/tcp --permanent || true
sudo firewall-cmd --reload || true

# ----- Task 3.4: advanced firewalld
info "Custom service and rich rules"
sudo firewall-cmd --permanent --new-service=myapp || true
sudo firewall-cmd --permanent --service=myapp --set-description="My Custom Application" || true
sudo firewall-cmd --permanent --service=myapp --set-short="MyApp" || true
sudo firewall-cmd --permanent --service=myapp --add-port=9090/tcp || true
sudo firewall-cmd --zone=public --add-service=myapp --permanent || true
sudo firewall-cmd --reload || true
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.100" service name="ssh" accept' --permanent || true
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.200" service name="http" drop' --permanent || true
sudo firewall-cmd --reload || true

# ----- Practical Scenarios
info "Scenario checks"
sudo netstat -tlnp | grep 8080 || true
sudo firewall-cmd --list-all || true

# ----- Verification
info "Verification suite"
ping -c 4 google.com || true
traceroute google.com || true
nslookup google.com || true
nslookup -type=MX google.com || true
sudo firewall-cmd --list-all || true
if command -v nmap >/dev/null 2>&1; then
  sudo nmap -p 22,80,443 localhost || true
else
  echo "nmap not installed; skipping port scan"
fi
nmcli connection show --active || true
ip addr show || true
ip route show || true

echo "Lab 14 script complete."
