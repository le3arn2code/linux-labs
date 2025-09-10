# interview_qna.md — 10 Network Troubleshooting Q&A (with Answers)

### 1) How do you quickly distinguish routing vs. DNS problems?
**Answer:** Ping an IP (e.g., `8.8.8.8`) to test routing; if that works but `ping google.com` fails, it’s DNS. Check `ip route show`, `/etc/resolv.conf`, and try `nslookup google.com 8.8.8.8`.

### 2) What does each hop in `traceroute` represent and why might it show `*`?
**Answer:** Each hop is a router along the path. `*` indicates no reply within TTL/timeout—due to rate‑limiting, filtering, or loss.

### 3) With NetworkManager, what’s the difference between a device and a connection?
**Answer:** The **device** is the interface (e.g., `ens33`), while a **connection** is a profile applied to a device (addresses, DNS, routes, autoconnect). Multiple profiles can exist per device.

### 4) How do you set and apply DNS servers to a connection with `nmcli`?
**Answer:** `nmcli connection modify <name> ipv4.dns "8.8.8.8,8.8.4.4"` then `nmcli connection up <name>`.

### 5) How would you open port 8080/tcp permanently in firewalld and verify?
**Answer:** `sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent && sudo firewall-cmd --reload` then `sudo firewall-cmd --zone=public --list-ports`.

### 6) When would you use rich rules in firewalld?
**Answer:** For granular policies (match on source IP, protocol, ports, actions). Example: allow SSH only from `192.168.1.100` with a rich rule.

### 7) `ping` fails but web browsing works—what’s happening?
**Answer:** ICMP may be blocked while TCP is allowed. Validate with `curl -I https://example.com` or check firewall policy for ICMP echo.

### 8) How can you revert a statically configured connection back to DHCP with `nmcli`?
**Answer:** `nmcli connection modify <name> ipv4.method auto && nmcli connection up <name>`.

### 9) Which command shows the default zone and all active zones in firewalld?
**Answer:** `firewall-cmd --get-default-zone` and `firewall-cmd --get-active-zones`.

### 10) How do you confirm a service is actually listening locally on a port?
**Answer:** `sudo ss -tulpen | grep :<port>` (or `sudo netstat -tlnp | grep :<port>` if installed). Combine with firewall checks to ensure external reachability.
