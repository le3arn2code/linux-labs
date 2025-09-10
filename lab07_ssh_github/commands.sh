#!/bin/bash
# Lab 7: Configuring and Securing SSH - Commands

# Check if OpenSSH server is installed
rpm -qa | grep openssh-server

# Install if not present
sudo dnf install openssh-server -y

# Check sshd service status
systemctl status sshd

# Start and enable sshd
sudo systemctl start sshd
sudo systemctl enable sshd
sudo systemctl status sshd

# Backup SSH configuration
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit sshd_config (manual step, not in script)

# Test configuration syntax
sudo sshd -t

# Restart SSH service
sudo systemctl restart sshd

# Firewall configuration
sudo firewall-cmd --state
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-services

# Create test user
sudo useradd testuser
sudo passwd testuser

# Test SSH connection locally
ssh testuser@localhost

# Remote SSH test (replace YOUR_IP_ADDRESS)
ssh testuser@YOUR_IP_ADDRESS
ssh -v testuser@YOUR_IP_ADDRESS

# Monitor SSH
sudo ss -tuln | grep :22
sudo journalctl -u sshd -f
sudo tail -f /var/log/secure

# Generate SSH keys on client
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key to remote
ssh-copy-id testuser@YOUR_IP_ADDRESS

# Set proper permissions
ssh testuser@YOUR_IP_ADDRESS "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

# Disable password authentication (edit sshd_config manually)
sudo sshd -t
sudo systemctl restart sshd

# Advanced SSH configurations (manual edits to sshd_config)
sudo systemctl restart sshd
