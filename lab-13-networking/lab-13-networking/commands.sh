#!/usr/bin/env bash
# Lab 13 — Configuring IP Addresses and Hostnames (RHEL 8/9)
# EXACT lab steps. Replace 'eth0' with your actual interface. Some steps require nano/editor (manual).
set -euo pipefail

info(){ printf "\n==> %s\n" "$*"; }
pause(){ printf "\n[MANUAL STEP REQUIRED]\n%s\n" "$*"; }

# ----- Task 1.1
info "Current network configuration"
nmcli connection show || true
nmcli connection show --active || true
ip addr show || true
systemctl status NetworkManager || true

# ----- Task 1.2
info "Create static-connection (replace eth0 if needed)"
nmcli device status || true
sudo nmcli connection add \
    type ethernet \
    con-name "static-connection" \
    ifname eth0 \
    ip4 192.168.1.100/24 \
    gw4 192.168.1.1 || true

sudo nmcli connection modify "static-connection" ipv4.dns "8.8.8.8,8.8.4.4" || true
sudo nmcli connection modify "static-connection" ipv4.method manual || true

# ----- Task 1.3
info "Activate and test static-connection"
sudo nmcli connection up "static-connection" || true
nmcli connection show --active || true
ip addr show eth0 || true
ping -c 4 8.8.8.8 || true

# ----- Task 2.1
info "Manage multiple connections"
nmcli device show || true
sudo nmcli connection add \
    type ethernet \
    con-name "backup-connection" \
    ifname eth0 \
    ip4 192.168.1.101/24 \
    gw4 192.168.1.1 || true

sudo nmcli connection modify "backup-connection" \
    ipv4.dns "1.1.1.1,1.0.0.1" \
    ipv4.method manual || true

# ----- Task 2.2
info "Switch to backup-connection"
nmcli connection show || true
sudo nmcli connection down "static-connection" || true
sudo nmcli connection up "backup-connection" || true
ip addr show eth0 || true
ping -c 4 google.com || true

# ----- Task 2.3
info "Configure autoconnect settings"
sudo nmcli connection modify "static-connection" connection.autoconnect yes || true
sudo nmcli connection modify "static-connection" connection.autoconnect-priority 10 || true
sudo nmcli connection modify "backup-connection" connection.autoconnect no || true

# ----- Task 3.1
info "Hostname information"
hostnamectl status || true
hostname || true
cat /etc/hostname || true

# ----- Task 3.2
info "Set hostnames (static, pretty, transient)"
sudo hostnamectl set-hostname "lab-server-01" || true
sudo hostnamectl set-hostname "Lab Server 01" --pretty || true
sudo hostnamectl set-hostname "temp-lab-server" --transient || true
hostnamectl status || true

# ----- Task 3.3
pause "Edit /etc/hosts and add:\n192.168.1.100    lab-server-01.localdomain    lab-server-01\nThen save and exit."
# Test hostname resolution
ping -c 2 lab-server-01 || true
command -v nslookup >/dev/null 2>&1 && nslookup lab-server-01 || echo "nslookup not found"
command -v dig >/dev/null 2>&1 && dig lab-server-01 || echo "dig not found"

# ----- Verification
info "Restart NetworkManager and verify persistence"
sudo systemctl restart NetworkManager || true
nmcli connection show --active || true
ip addr show || true
hostnamectl status || true
hostname -f || true
ping -c 4 8.8.8.8 || true
ping -c 4 google.com || true
ping -c 2 lab-server-01 || true
command -v nslookup >/dev/null 2>&1 && nslookup google.com || echo "nslookup not found"
command -v dig >/dev/null 2>&1 && dig google.com || echo "dig not found"

# ----- Cleanup (optional, manual execution recommended)
echo "Optional cleanup commands:"
echo "  sudo nmcli connection delete \"static-connection\""
echo "  sudo nmcli connection delete \"backup-connection\""
echo "  sudo hostnamectl set-hostname \"localhost.localdomain\""

echo "Lab 13 script complete."
