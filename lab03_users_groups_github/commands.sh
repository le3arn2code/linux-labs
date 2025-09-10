#!/usr/bin/env bash
# Lab 3: Managing Users and Groups — Commands
set -euo pipefail

# Inspect current users (last 5 entries)
cat /etc/passwd | tail -5
whoami

# Become root if needed (uncomment if using a non-root shell)
# sudo su -

# --- Create users ---
useradd john
grep john /etc/passwd
ls -la /home/

useradd -d /home/custom_jane jane
useradd -s /bin/bash mike
useradd -c "Sarah Johnson" sarah
useradd -u 1500 tom
useradd -c "Alice Smith" -d /home/alice_home -s /bin/bash -u 1501 alice

# Verify users created
grep -E "john|jane|mike|sarah|tom|alice" /etc/passwd
ls -la /home/
id john || true
id alice || true

# --- Set passwords (interactive; comment kept for documentation) ---
# passwd john
# passwd jane
# passwd mike
# passwd sarah

# --- Modify user details ---
usermod -c "John Doe - Developer" john
usermod -d /home/john_new john
usermod -s /bin/zsh sarah || true   # may fail if /bin/zsh not installed
usermod -u 1502 mike
usermod -L tom
usermod -U tom

# Verify modifications
grep -E "john|sarah|mike|tom" /etc/passwd
passwd -S john || true
passwd -S tom || true

# --- Groups: create ---
groupadd developers
groupadd testers
groupadd managers
groupadd -g 2000 admins
groupadd -r sysops

# Verify groups
grep -E "developers|testers|managers|admins|sysops" /etc/group
getent group developers
getent group admins

# --- Group memberships ---
usermod -g developers john                    # primary group
usermod -G testers,managers jane              # secondary groups (overwrites previous secondary)
usermod -a -G developers,admins mike          # append mode
gpasswd -a sarah developers
gpasswd -M alice,tom testers

# Verify memberships
groups john || true
groups jane || true
groups mike || true
getent group developers
getent group testers
getent group managers
id john || true
id jane || true

# --- Group modifications ---
groupmod -n development developers
groupmod -g 2001 admins
getent group development
getent group admins

# --- Clean up memberships before deletions ---
gpasswd -d tom testers || true
usermod -G "" alice || true
groups tom || true
groups alice || true

# --- Delete users ---
userdel tom || true                     # keep home
userdel -r alice || true                # remove home
userdel -f mike || true                 # force
grep -E "tom|alice|mike" /etc/passwd || true
ls -la /home/ || true

# --- Delete groups ---
getent group testers || true
groupdel testers || true
groupdel development || true            # may fail if has members
gpasswd -d john development || true
gpasswd -d sarah development || true
groupdel development || true
getent group testers || true
getent group development || true

# --- Final cleanup ---
userdel -r john || true
userdel -r jane || true
userdel -r sarah || true

groupdel managers || true
groupdel admins || true
groupdel sysops || true

# Verify cleanup
grep -E "john|jane|sarah|tom|alice|mike" /etc/passwd || true
grep -E "developers|testers|managers|admins|sysops|development" /etc/group || true

# --- Security practices ---
# Password aging examples (documentation purposes; adjust username accordingly)
# chage -M 90 username
# chage -m 7 username
# chage -W 7 username
# chage -l username
# chage -E 2024-12-31 username
# usermod -L -e 1 username   # disable account

echo "Lab 3 - Managing Users and Groups completed successfully!"
