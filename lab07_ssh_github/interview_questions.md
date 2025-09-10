# SSH Interview Questions and Answers

### 1. What is SSH and why is it important?
**Answer:** SSH (Secure Shell) is a protocol for securely accessing and managing remote systems over an encrypted channel. It is essential for secure remote administration.

### 2. How do you install and enable the SSH server on RHEL/CentOS?
**Answer:** Use `sudo dnf install openssh-server -y` to install, then `sudo systemctl start sshd` and `sudo systemctl enable sshd` to enable it.

### 3. Which file contains the main SSH server configuration?
**Answer:** `/etc/ssh/sshd_config`

### 4. How do you disable root login via SSH?
**Answer:** Set `PermitRootLogin no` in `/etc/ssh/sshd_config` and restart the sshd service.

### 5. What are the benefits of key-based authentication over password-based authentication?
**Answer:** Key-based authentication is more secure, prevents brute-force password attacks, and can be automated for scripts without requiring passwords.

### 6. How do you test SSH configuration for errors before restarting?
**Answer:** Run `sudo sshd -t` to check for syntax errors.

### 7. Which firewall command allows SSH traffic permanently?
**Answer:** `sudo firewall-cmd --permanent --add-service=ssh` followed by `sudo firewall-cmd --reload`

### 8. How can you monitor active SSH sessions?
**Answer:** Use `who`, `w`, or `sudo ss -tuln | grep :22`. Logs can be checked with `sudo journalctl -u sshd -f`.

### 9. How do you disable password authentication entirely?
**Answer:** In `sshd_config`, set `PasswordAuthentication no`, then restart the sshd service.

### 10. What are some SSH hardening best practices?
**Answer:** 
- Change default port from 22
- Disable root login
- Use key-based authentication
- Limit users with `AllowUsers`
- Disable unused features (X11 forwarding, TCP forwarding)
- Use strong ciphers and MACs
