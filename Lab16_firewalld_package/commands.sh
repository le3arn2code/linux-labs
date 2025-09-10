#!/usr/bin/env bash
# Lab 16 - Configuring firewalld for Network Security
# This script is idempotent and safe to re-run on RHEL/CentOS 8/9.
set -euo pipefail

log() { printf "\n\033[1;36m[LAB16]\033[0m %s\n" "$*"; }
warn() { printf "\n\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\n\033[1;31m[ERROR]\033[0m %s\n" "$*"; }

detect_iface() {
  # Try default route interface, fallback to first non-loopback
  IFACE="$(ip -o -4 route show to default 2>/dev/null | awk '{print $5}' | head -n1 || true)"
  if [[ -z "${IFACE:-}" ]]; then
    IFACE="$(ip -o link show | awk -F': ' '$2 !~ /lo/ {print $2}' | head -n1 || true)"
  fi
  echo "${IFACE:-}"
}

pkg_install() {
  local pkg="$1"
  if ! rpm -q "$pkg" >/dev/null 2>&1; then
    sudo dnf install -y "$pkg"
  fi
}

log "1) Ensure required packages are installed"
# firewalld + test tools
pkg_install firewalld
pkg_install httpd
pkg_install nmap
# netcat (RHEL provides nmap-ncat which offers 'ncat'/'nc')
if ! command -v nc >/dev/null 2>&1 && ! rpm -q nmap-ncat >/dev/null 2>&1; then
  pkg_install nmap-ncat
fi
# telnet client is optional; install if available
if ! command -v telnet >/dev/null 2>&1; then
  if dnf info -y telnet >/dev/null 2>&1; then
    pkg_install telnet
  else
    warn "Package 'telnet' not available; skipping telnet-based tests."
  fi
fi

log "2) Start and enable firewalld (and ensure no iptables conflict)"
# Stop classic iptables service if present (rare on RHEL 8/9 but included for completeness)
if systemctl list-unit-files | grep -q '^iptables\.service'; then
  sudo systemctl stop iptables || true
  sudo systemctl disable iptables || true
fi
sudo systemctl enable --now firewalld
sleep 1
sudo firewall-cmd --state

log "3) Basic firewalld inspection"
sudo firewall-cmd --list-all || true
sudo firewall-cmd --get-zones || true
sudo firewall-cmd --get-default-zone || true
sudo firewall-cmd --get-active-zones || true

log "4) Create basic rules (HTTP/HTTPS, 8080, 3000-3005)"
sudo firewall-cmd --add-service=http || true
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3000-3005/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

log "5) Advanced rules (sources + rich rules) in the default zone"
# Note: These apply to the default zone unless --zone is given
sudo firewall-cmd --permanent --add-source=192.168.1.100
sudo firewall-cmd --permanent --add-source=192.168.1.0/24
sudo firewall-cmd --permanent --add-rich-rule='rule source address="192.168.1.50" drop'
sudo firewall-cmd --permanent --add-rich-rule='rule source address="192.168.1.100" service name="ssh" accept'
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
sudo firewall-cmd --list-rich-rules

log "6) Create custom zone 'webserver' and configure it"
if ! sudo firewall-cmd --get-zones | tr ' ' '\n' | grep -qx webserver; then
  sudo firewall-cmd --permanent --new-zone=webserver
  sudo firewall-cmd --reload
fi
sudo firewall-cmd --permanent --zone=webserver --add-service=http
sudo firewall-cmd --permanent --zone=webserver --add-service=https
sudo firewall-cmd --permanent --zone=webserver --add-service=ssh
sudo firewall-cmd --permanent --zone=webserver --add-port=8080/tcp
# set description (supported in modern firewalld)
if sudo firewall-cmd --help 2>/dev/null | grep -q -- '--set-description'; then
  sudo firewall-cmd --permanent --zone=webserver --set-description="Web Server Zone for HTTP/HTTPS traffic"
fi
sudo firewall-cmd --reload
sudo firewall-cmd --zone=webserver --list-all

log "7) Assign active interface to 'webserver' zone"
IFACE="$(detect_iface)"
if [[ -n "$IFACE" ]]; then
  sudo firewall-cmd --permanent --zone=webserver --change-interface="$IFACE" || true
  sudo firewall-cmd --reload
  sudo firewall-cmd --get-active-zones
else
  warn "Could not detect a non-loopback interface; skip interface assignment."
fi

log "8) Configure internal and dmz zones"
sudo firewall-cmd --permanent --zone=internal --add-service=ssh
sudo firewall-cmd --permanent --zone=internal --add-service=samba
sudo firewall-cmd --permanent --zone=internal --add-service=nfs
sudo firewall-cmd --permanent --zone=internal --add-source=192.168.1.0/24
sudo firewall-cmd --permanent --zone=internal --add-source=10.0.0.0/8
sudo firewall-cmd --permanent --zone=dmz --add-service=http
sudo firewall-cmd --permanent --zone=dmz --add-service=https
sudo firewall-cmd --permanent --zone=dmz --add-port=8080/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --zone=internal --list-all
sudo firewall-cmd --zone=dmz --list-all

log "9) Add rich rules (rate-limit SSH, global drops with logging)"
sudo firewall-cmd --permanent --add-rich-rule='rule source address="192.168.1.0/24" service name="ssh" accept'
sudo firewall-cmd --permanent --zone=internal --add-rich-rule='rule source address="0.0.0.0/0" drop'
sudo firewall-cmd --permanent --zone=internal --add-rich-rule='rule source address="192.168.1.0/24" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule service name="ssh" accept limit value="3/m"'
sudo firewall-cmd --permanent --add-rich-rule='rule drop log prefix="FIREWALL-DROP: " level="warning"'
sudo firewall-cmd --reload
sudo firewall-cmd --list-rich-rules

log "10) Start Apache and create a test page"
sudo systemctl enable --now httpd
echo "<h1>Firewall Test Page</h1>" | sudo tee /var/www/html/index.html >/dev/null

log "11) Basic tests"
set +e
curl -s -I http://localhost || true
nmap -p 80 localhost || true
nmap -p 22,80,443,8080 localhost || true
if command -v telnet >/dev/null 2>&1; then
  (echo quit | telnet localhost 8080) || true
fi
nc -zv localhost 3306 || true
set -e

log "12) Show final verification hints"
echo -e "
Run these to inspect the final state:
  sudo firewall-cmd --state
  sudo firewall-cmd --get-default-zone
  sudo firewall-cmd --get-active-zones
  sudo firewall-cmd --list-all
  sudo firewall-cmd --list-all --permanent
  sudo firewall-cmd --list-rich-rules
  sudo journalctl -u firewalld -f
"

log "DONE. Lab 16 configuration completed successfully."
