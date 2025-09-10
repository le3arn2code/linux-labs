# interview_qna.md — 10 Networking (nmcli & hostnamectl) Questions **with Answers**

### 1) What’s the difference between a *connection* and a *device* in NetworkManager?
**Answer:** A **device** is the network interface (e.g., `ens33`), while a **connection** is a profile of settings (IP, DNS, routes) applied to a device. Multiple connections can target the same device; only one is active per device at a time.

### 2) How do you set a static IPv4 address with nmcli?
**Answer:** Create/modify a connection with `ipv4.method manual`, set `ipv4.addresses` (or `ip4` during add) and `ipv4.gateway`, add `ipv4.dns`, then `nmcli connection up <name>`.

### 3) How do you switch between two profiles on the same interface?
**Answer:** Bring the current one down and the other up: `nmcli connection down <A>; nmcli connection up <B>`. If the device sticks, `nmcli device disconnect <ifname>` then `connection up` the desired profile.

### 4) How do you ensure a connection auto‑activates on boot and takes precedence?
**Answer:** `nmcli connection modify <name> connection.autoconnect yes` and adjust `connection.autoconnect-priority` (higher wins).

### 5) What are static, pretty, and transient hostnames?
**Answer:** **Static:** persisted in `/etc/hostname`; **Pretty:** human‑friendly display name; **Transient:** temporary, usually from DHCP or set until reboot.

### 6) Why might `hostname -f` be empty on a correctly set hostname?
**Answer:** Forward DNS or `/etc/hosts` doesn’t map the host’s IP to a FQDN. Add `<IP> <fqdn> <shortname>` to `/etc/hosts` or ensure DNS has proper A/PTR records.

### 7) How do you list devices and see which one is connected?
**Answer:** `nmcli device status` for summary; `nmcli device show <ifname>` for details. Active connections are shown with `nmcli connection show --active`.

### 8) What commands verify routing and DNS issues quickly?
**Answer:** `ip route show` (default route), `resolvectl status` or `cat /etc/resolv.conf` (DNS), `ping 8.8.8.8` vs `ping google.com` to distinguish routing vs DNS.

### 9) How do you safely test DNS when `nslookup`/`dig` are missing?
**Answer:** Use `getent hosts <name>` or `ping -c1 <name>`. Install `bind-utils` for `dig`/`nslookup` on RHEL/CentOS (`dnf install -y bind-utils`).

### 10) How do you delete a connection and revert to DHCP quickly?
**Answer:** `nmcli connection delete <name>` and reactivate the DHCP profile (e.g., “Wired connection 1”) or add a DHCP profile with `ipv4.method auto` then `nmcli connection up` it.
