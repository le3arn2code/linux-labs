# Lab 14 — Troubleshooting Network Connectivity (RHEL/CentOS)

> **Environment:** Al‑Nafi cloud VM • **OS:** RHEL/CentOS 8/9 • **Access:** root/sudo • **Tools:** ping, traceroute, nslookup, nmcli, firewalld

## Objectives
- Test connectivity with **ping**, **traceroute**, **nslookup**
- Interpret diagnostic output
- View/manage network with **nmcli**
- Configure firewall rules with **firewalld**
- Troubleshoot common connectivity issues
- Apply a systematic resolution approach

## Prerequisites
- Linux CLI basics; editing files
- Networking basics (IP, DNS, ports)
- sudo/root access

## Lab Environment Setup
- Pre‑configured RHEL/CentOS VM with network tools
- Root access
- Internet connectivity
- Pre‑configured interfaces

---

## Task 1: Testing Network Connectivity with Basic Tools

### Subtask 1.1: Using the `ping` Command
**Step 1: Test Local Connectivity**
```bash
ping -c 4 127.0.0.1
```
*Expected Output (example):*
```
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.045 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.037 ms
64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.039 ms
64 bytes from 127.0.0.1: icmp_seq=4 ttl=64 time=0.041 ms
```

**Step 2: Test Gateway Connectivity**
```bash
ip route show default
ping -c 4 192.168.1.1   # replace with your actual gateway IP
```

**Step 3: Test External Connectivity**
```bash
# Test Google's public DNS
ping -c 4 8.8.8.8

# Test a domain name
ping -c 4 google.com
```

### Subtask 1.2: Using the `traceroute` Command
**Step 1: Install traceroute (if needed)**
```bash
# RHEL/CentOS (YUM)
sudo yum install -y traceroute

# RHEL/CentOS (DNF)
sudo dnf install -y traceroute
```

**Step 2: Trace Route to External Host**
```bash
traceroute google.com
```
*Each line is a hop; three RTTs per probe.*

**Step 3: Trace Route with IP Addresses Only**
```bash
traceroute -n 8.8.8.8   # -n disables DNS lookups
```

### Subtask 1.3: Using the `nslookup` Command
**Step 1: Basic DNS Lookup**
```bash
nslookup google.com
```

**Step 2: Reverse DNS Lookup**
```bash
nslookup 8.8.8.8
```

**Step 3: Query Specific DNS Record Types**
```bash
# MX records (mail)
nslookup -type=MX google.com

# NS records (name servers)
nslookup -type=NS google.com
```

**Step 4: Use a Specific DNS Server**
```bash
nslookup google.com 8.8.8.8
```

---

## Task 2: Managing Network Configurations with `nmcli`

### Subtask 2.1: Viewing Current Network Status
**Step 1: Check NetworkManager Status**
```bash
nmcli general status
```

**Step 2: List All Network Devices**
```bash
nmcli device status
```

**Step 3: Show Detailed Device Information**
```bash
nmcli device show
```

### Subtask 2.2: Managing Network Connections
**Step 1: List All Connections**
```bash
nmcli connection show
```

**Step 2: Show Active Connections**
```bash
nmcli connection show --active
```

**Step 3: View Detailed Connection Information**
*(replace `connection-name`)*
```bash
nmcli connection show "System eth0"
```

### Subtask 2.3: Modifying Network Settings
**Step 1: Change DNS Settings**
```bash
# Add DNS to existing connection
sudo nmcli connection modify "System eth0" ipv4.dns "8.8.8.8,8.8.4.4"

# Apply the changes
sudo nmcli connection up "System eth0"
```

**Step 2: Set Static IP Address**
```bash
# Replace with appropriate values
sudo nmcli connection modify "System eth0" ipv4.addresses "192.168.1.100/24"
sudo nmcli connection modify "System eth0" ipv4.gateway "192.168.1.1"
sudo nmcli connection modify "System eth0" ipv4.method manual

# Restart the connection
sudo nmcli connection up "System eth0"
```

**Step 3: Revert to DHCP**
```bash
sudo nmcli connection modify "System eth0" ipv4.method auto
sudo nmcli connection up "System eth0"
```

### Subtask 2.4: Creating New Network Connections
**Step 1: Create a New Ethernet Connection**
```bash
sudo nmcli connection add type ethernet con-name "lab-connection" ifname eth0
```

**Step 2: Configure the New Connection**
```bash
sudo nmcli connection modify "lab-connection" ipv4.addresses "192.168.1.150/24"
sudo nmcli connection modify "lab-connection" ipv4.gateway "192.168.1.1"
sudo nmcli connection modify "lab-connection" ipv4.dns "8.8.8.8"
sudo nmcli connection modify "lab-connection" ipv4.method manual
```

**Step 3: Activate the New Connection**
```bash
sudo nmcli connection up "lab-connection"
```

---

## Task 3: Configuring Firewall Rules with `firewalld`

### Subtask 3.1: Understanding Firewalld Basics
**Step 1: Check Firewalld Status**
```bash
sudo systemctl status firewalld
# If not running:
sudo systemctl start firewalld
sudo systemctl enable firewalld
```

**Step 2: View Current Firewall Configuration**
```bash
# Show default zone
sudo firewall-cmd --get-default-zone

# List all zones
sudo firewall-cmd --get-zones

# Show active zones
sudo firewall-cmd --get-active-zones
```

**Step 3: View Zone Configuration**
```bash
# Default zone
sudo firewall-cmd --list-all

# Specific zone
sudo firewall-cmd --zone=public --list-all
```

### Subtask 3.2: Managing Firewall Services
**Step 1: List Available Services**
```bash
sudo firewall-cmd --get-services
```

**Step 2: Add Services to Firewall**
```bash
# Allow HTTP
sudo firewall-cmd --zone=public --add-service=http --permanent

# Allow HTTPS
sudo firewall-cmd --zone=public --add-service=https --permanent

# Allow SSH (usually already enabled)
sudo firewall-cmd --zone=public --add-service=ssh --permanent
```

**Step 3: Reload Firewall Configuration**
```bash
sudo firewall-cmd --reload
```

**Step 4: Verify Services Are Added**
```bash
sudo firewall-cmd --zone=public --list-services
```

### Subtask 3.3: Managing Firewall Ports
**Step 1: Open Specific Ports**
```bash
# Open port 8080 TCP
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent

# Open port 53 UDP (DNS)
sudo firewall-cmd --zone=public --add-port=53/udp --permanent

# Open a range of ports
sudo firewall-cmd --zone=public --add-port=3000-3005/tcp --permanent
```

**Step 2: Reload and Verify**
```bash
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-ports
```

**Step 3: Remove Ports**
```bash
sudo firewall-cmd --zone=public --remove-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

### Subtask 3.4: Advanced Firewall Configuration
**Step 1: Create Custom Service**
```bash
sudo firewall-cmd --permanent --new-service=myapp
sudo firewall-cmd --permanent --service=myapp --set-description="My Custom Application"
sudo firewall-cmd --permanent --service=myapp --set-short="MyApp"
sudo firewall-cmd --permanent --service=myapp --add-port=9090/tcp
```

**Step 2: Add Custom Service to Zone**
```bash
sudo firewall-cmd --zone=public --add-service=myapp --permanent
sudo firewall-cmd --reload
```

**Step 3: Configure Rich Rules**
```bash
# Allow specific IP to access SSH
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.100" service name="ssh" accept' --permanent

# Block specific IP from accessing HTTP
sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.200" service name="http" drop' --permanent

sudo firewall-cmd --reload
```

---

## Practical Troubleshooting Scenarios

### Scenario 1: Cannot Reach External Websites
**Problem:** User cannot browse websites.  
**Steps:**
```bash
ping 127.0.0.1
ip route show default
ping -c 4 <gateway-ip>
nslookup google.com
ping -c 4 8.8.8.8
```

### Scenario 2: Service Not Accessible
**Problem:** Web service on port 8080 not reachable from other hosts.  
**Steps:**
```bash
sudo netstat -tlnp | grep 8080
sudo firewall-cmd --list-all
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

### Scenario 3: DNS Resolution Issues
**Problem:** Can ping IPs, but names fail.  
**Steps:**
```bash
cat /etc/resolv.conf
nslookup google.com 8.8.8.8
nslookup google.com 1.1.1.1
sudo nmcli connection modify "System eth0" ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli connection up "System eth0"
```

---

## Verification and Testing

**Connectivity Test**
```bash
ping -c 4 google.com
traceroute google.com
```

**DNS Test**
```bash
nslookup google.com
nslookup -type=MX google.com
```

**Firewall Test**
```bash
sudo firewall-cmd --list-all
sudo nmap -p 22,80,443 localhost
```

**Network Configuration Test**
```bash
nmcli connection show --active
ip addr show
ip route show
```

---

## Conclusion
You used core tools to diagnose connectivity, managed connections with **nmcli**, and configured access control with **firewalld**—a practical toolkit for RHCSA‑level network troubleshooting.
