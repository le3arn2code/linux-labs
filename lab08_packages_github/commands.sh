#!/usr/bin/env bash
# Lab 8: Installing and Managing Software Packages — Commands (no deviations)
set -euo pipefail

# --- Task 1: Package Managers ---
which dnf || true
which yum || true
dnf --version || true
yum --version || true

# Update repository metadata
sudo dnf update || sudo yum update

# --- Subtask 1.4: Installing Individual Packages ---
# nano
sudo dnf install nano -y
which nano
nano --version || true

# htop
sudo dnf install htop -y
htop --version || true

# wget
sudo dnf install wget -y
wget --version || true

# --- Subtask 1.5: Install Multiple Packages ---
sudo dnf install tree unzip zip curl -y
tree --version || true
unzip -v | head -1 || true
zip -v | head -1 || true
curl --version | head -1 || true

# --- Subtask 1.6: Package Groups ---
dnf group list
sudo dnf group install "Development Tools" -y
gcc --version || true

# --- Task 2: Querying Installed Packages ---

# RPM queries
rpm -qa | head -20
rpm -qa | wc -l
rpm -q nano
rpm -qi nano
rpm -ql nano | head -10
rpm -qf /usr/bin/nano

# DNF queries
dnf search editor
dnf list nano
dnf list installed | head -20
dnf info nano
dnf deplist nano
dnf check-update || true

# Advanced
dnf provides /usr/bin/python3
dnf provides "*/bin/gcc"
dnf history list | head -10
dnf repolist
dnf repolist all
# If EPEL is configured:
dnf repository-packages epel list || true

# --- Task 3: Removing and Updating Packages ---

# Remove a single package
sudo dnf remove tree -y || true
which tree || true

# Dependencies example
sudo dnf install httpd -y
dnf deplist httpd
sudo dnf remove httpd -y
sudo dnf autoremove -y

# Update a specific package
rpm -q kernel || true
sudo dnf update nano -y
dnf info nano

# Update all packages
dnf check-update || true
sudo dnf update -y
dnf history list | head -5

# Reinstall & downgrade examples
sudo dnf reinstall nano -y
dnf list nano --showduplicates
# Example downgrade (version depends on repos)
# sudo dnf downgrade nano-<version>

# Manage cache
du -sh /var/cache/dnf/ || true
sudo dnf clean all
du -sh /var/cache/dnf/ || true

# --- Practical Exercise: Web Dev Environment ---

sudo dnf install httpd php php-mysql mariadb-server git -y
rpm -q httpd php php-mysql mariadb-server git
rpm -ql httpd | grep bin || true

sudo systemctl start httpd
sudo systemctl enable httpd
systemctl status httpd || true

dnf check-update httpd php php-mysql mariadb-server git || true
sudo dnf update httpd php php-mysql mariadb-server git -y || true

# Optional cleanup
sudo systemctl stop httpd || true
sudo systemctl disable httpd || true
sudo dnf remove httpd php php-mysql mariadb-server -y || true
sudo dnf autoremove -y || true

echo "Lab 8 — Completed per instructions."
