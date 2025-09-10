# Lab 13 — Configuring IP Addresses and Hostnames (RHEL 8/9)

> **Environment:** Al‑Nafi cloud VM • **OS:** RHEL 8/9 • **Manager:** NetworkManager • **Access:** root/sudo

## Objectives
- Configure static IP addresses using the **nmcli** CLI
- Set up and manage network interfaces
- Modify hostnames with **hostnamectl**
- Understand the relationship between IPs, interfaces, and hostnames
- Troubleshoot basic connectivity
- Verify changes and ensure persistence across reboots

## Prerequisites
- Basic Linux CLI, vi/nano
- Basic networking (IP/subnet/gateway/DNS)
- sudo access

## Lab Environment
- RHEL 8/9 with **NetworkManager** running
- Internet connectivity for testing

---

## Task 1: Configure Static IP Addresses with nmcli

### Subtask 1.1: Understanding Current Network Configuration
**Step 1:** Check current network connections  
```bash
nmcli connection show
```
**Step 2:** Detailed info about active connections  
```bash
nmcli connection show --active
```
**Step 3:** View current IP address configuration  
```bash
ip addr show
```
**Step 4:** Check NetworkManager service  
```bash
systemctl status NetworkManager
```

### Subtask 1.2: Creating a New Static IP Connection
**Step 1:** Identify your network interface name  
```bash
nmcli device status
```
> Replace `eth0` in the following commands with your actual interface name.

**Step 2:** Create a new connection profile with static IP  
```bash
sudo nmcli connection add     type ethernet     con-name "static-connection"     ifname eth0     ip4 192.168.1.100/24     gw4 192.168.1.1
```

**Step 3:** Add DNS servers  
```bash
sudo nmcli connection modify "static-connection"     ipv4.dns "8.8.8.8,8.8.4.4"
```

**Step 4:** Set manual (static) mode  
```bash
sudo nmcli connection modify "static-connection"     ipv4.method manual
```

### Subtask 1.3: Activating and Testing the Static Connection
**Step 1:** Activate the new connection  
```bash
sudo nmcli connection up "static-connection"
```
**Step 2:** Verify active connections  
```bash
nmcli connection show --active
```
**Step 3:** Check new IP assignment  
```bash
ip addr show eth0
```
**Step 4:** Test connectivity  
```bash
ping -c 4 8.8.8.8
```

---

## Task 2: Set Up Network Interfaces

### Subtask 2.1: Managing Multiple Network Connections
**Step 1:** List all network devices  
```bash
nmcli device show
```
**Step 2:** Create a backup profile  
```bash
sudo nmcli connection add     type ethernet     con-name "backup-connection"     ifname eth0     ip4 192.168.1.101/24     gw4 192.168.1.1
```
**Step 3:** Configure DNS & manual mode for backup  
```bash
sudo nmcli connection modify "backup-connection"     ipv4.dns "1.1.1.1,1.0.0.1"     ipv4.method manual
```

### Subtask 2.2: Switching Between Network Connections
**Step 1:** View all profiles  
```bash
nmcli connection show
```
**Step 2:** Switch to backup  
```bash
sudo nmcli connection down "static-connection"
sudo nmcli connection up "backup-connection"
```
**Step 3:** Verify IP change  
```bash
ip addr show eth0
```
**Step 4:** Test connectivity  
```bash
ping -c 4 google.com
```

### Subtask 2.3: Configuring Connection Auto‑Connect
**Step 1:** Enable auto‑connect for primary  
```bash
sudo nmcli connection modify "static-connection"     connection.autoconnect yes
```
**Step 2:** Set connection priority  
```bash
sudo nmcli connection modify "static-connection"     connection.autoconnect-priority 10
```
**Step 3:** Disable auto‑connect for backup  
```bash
sudo nmcli connection modify "backup-connection"     connection.autoconnect no
```

---

## Task 3: Modify Hostnames Using hostnamectl

### Subtask 3.1: Current Hostname Configuration
**Step 1:** Display hostname info  
```bash
hostnamectl status
```
**Step 2:** Show only current hostname  
```bash
hostname
```
**Step 3:** Check hostname file  
```bash
cat /etc/hostname
```

### Subtask 3.2: Setting Different Types of Hostnames
**Step 1:** Set the static hostname  
```bash
sudo hostnamectl set-hostname "lab-server-01"
```
**Step 2:** Set a pretty hostname  
```bash
sudo hostnamectl set-hostname "Lab Server 01" --pretty
```
**Step 3:** Set a transient hostname  
```bash
sudo hostnamectl set-hostname "temp-lab-server" --transient
```
**Step 4:** Verify all hostname settings  
```bash
hostnamectl status
```

### Subtask 3.3: Configuring Hostname Resolution
**Step 1:** Edit `/etc/hosts`  
```bash
sudo nano /etc/hosts
```
**Step 2:** Add this line and save:  
```
192.168.1.100    lab-server-01.localdomain    lab-server-01
```
**Step 3:** Test hostname resolution  
```bash
ping -c 2 lab-server-01
```
**Step 4:** Verify reverse lookup  
```bash
nslookup lab-server-01
```

---

## Verification and Testing

**Step 1:** Restart NetworkManager  
```bash
sudo systemctl restart NetworkManager
```
**Step 2:** Verify network configuration persists  
```bash
nmcli connection show --active
ip addr show
```
**Step 3:** Test hostname persistence  
```bash
hostnamectl status
hostname -f
```
**Step 4:** Connectivity tests  
```bash
ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 2 lab-server-01
```
**Step 5:** Check DNS resolution  
```bash
nslookup google.com
dig google.com
```

---

## Troubleshooting Common Issues (see `troubleshooting.md` for full details)
- Interface name mismatch (`eth0` vs `ens...`): use `nmcli device status`.
- Conflicting auto‑connected profiles: down or remove the conflicting one.
- No `nslookup`/`dig`: install `bind-utils`.
- Hostname not persisting: permissions and `systemd-hostnamed` restart.
- No internet: verify gateway & DNS, check default route.

---

## Lab Cleanup (Optional)
```bash
sudo nmcli connection delete "static-connection"
sudo nmcli connection delete "backup-connection"
sudo hostnamectl set-hostname "localhost.localdomain"
# Restore /etc/hosts manually from your backup if needed
```

## Conclusion
You configured static IPs with **nmcli**, managed multiple profiles, set hostnames (static/pretty/transient), and validated persistence and connectivity—foundational skills for enterprise Linux networking.
