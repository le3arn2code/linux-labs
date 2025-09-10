# Lab 7: Configuring and Securing SSH

## Objectives
- Install and configure OpenSSH server on a Linux system
- Understand SSH service configuration files and security settings
- Test SSH connections both locally and remotely
- Configure key-based authentication for enhanced security
- Implement SSH security best practices
- Troubleshoot common SSH connection issues
- Manage SSH keys and user access

## Tasks Covered
1. Install and configure OpenSSH server
2. Start and enable SSH service
3. Modify sshd_config for security
4. Configure firewall for SSH
5. Test local and remote SSH connections
6. Set up SSH key-based authentication
7. Disable password authentication
8. Apply advanced SSH security settings
9. Troubleshoot SSH issues

## Troubleshooting Covered
- Connection refused errors: check sshd service, firewall, and config syntax
- Permission denied errors: verify permissions of ~/.ssh and authorized_keys
- Key authentication not working: ensure correct key in authorized_keys and SELinux context
- Use journalctl and verbose SSH output for debugging

## Verification Commands
```bash
sudo systemctl status sshd
sudo sshd -t
sudo ss -tuln | grep :22
sudo journalctl -u sshd -n 10
ssh -T testuser@localhost
```

## Outcomes
- Secure and functional SSH configuration achieved
- Local and remote SSH access tested
- Key-based authentication implemented
- SSH hardened with recommended security settings

---
