#!/usr/bin/env bash
# Lab 6: Working with vim and nano — Commands
set -euo pipefail

# --- Task 1: Setup ---
mkdir -p ~/text-editor-lab
cd ~/text-editor-lab
pwd

which vim || true
which nano || true
vim --version | head -1 || true
nano --version | head -1 || true

# --- Task 2: nano workflow ---
# Interactive steps (as practiced):
# nano server-config.txt
#   - Type given config
#   - Ctrl+K to cut 'port=8080', move cursor, Ctrl+U to paste
#   - Ctrl+O, Enter, Ctrl+X
# For reproducibility, create file non-interactively:
cat > server-config.txt <<'EOF'
# Server Configuration File
# Created on: [Today's Date]

server_name=web-server-01
port=8080
max_connections=100
timeout=30
debug_mode=false

# Database Settings
db_host=localhost
db_port=3306
db_name=webapp
EOF

# Append security settings (simulating re-open, edit, save):
cat >> server-config.txt <<'EOF'

# Security Settings
ssl_enabled=true
ssl_port=443
encryption=AES256
EOF

ls -la server-config.txt
cat server-config.txt

# --- Task 3: vim workflow ---
# Interactive steps (as practiced):
# vim network-settings.conf
#   i (Insert), type content, Esc, navigation (h j k l / w b 0 $ gg G),
#   yy/p duplication, edit clone to dns_tertiary, :wq
# For reproducibility:
cat > network-settings.conf <<'EOF'
# Network Configuration
# System: RHEL/CentOS

interface=eth0
ip_address=192.168.1.100
subnet_mask=255.255.255.0
gateway=192.168.1.1
dns_primary=8.8.8.8
dns_secondary=8.8.4.4

# Network Services
ssh_enabled=yes
firewall_enabled=yes
EOF

# Simulate copy of dns_primary line and add tertiary
awk '1; /dns_primary=8.8.8.8/ {print "dns_tertiary=1.1.1.1"}' network-settings.conf > .tmp && mv .tmp network-settings.conf

# Verify and simulate :%s/server/node/g later on a different file
ls -la network-settings.conf
cat network-settings.conf

# --- Task 4: Comparing editors ---
cat > comparison-nano.txt <<'EOF'
Editor: nano
Ease of use: Beginner-friendly
Learning curve: Gentle
Best for: Quick edits, beginners
Commands visible: Yes
EOF

cat > comparison-vim.txt <<'EOF'
Editor: vim
Ease of use: Advanced users
Learning curve: Steep
Best for: Complex editing, programming
Commands visible: No
EOF

cat comparison-nano.txt
echo "---"
cat comparison-vim.txt

# --- Task 5: Practical scenarios ---
# 5.1 nano quick config
cat > /tmp/httpd.conf <<'EOF'
# Apache HTTP Server Configuration
ServerRoot "/etc/httpd"
Listen 80
ServerName localhost:80
DocumentRoot "/var/www/html"

# Security Settings
ServerTokens Prod
ServerSignature Off

# Performance Settings
MaxRequestWorkers 150
ThreadsPerChild 25
EOF

# 5.2 vim complex editing
cat > /tmp/complex-config.conf <<'EOF'
# Multi-service Configuration
[database]
host=db-node-01
port=5432
username=admin
password=temp123

[webserver]
host=web-node-01
port=80
ssl_port=443
document_root=/var/www

[cache]
host=cache-node-01
port=6379
memory_limit=512M
EOF

# Simulate cw change of password and :%s/server/node/g
sed -i 's/password=temp123/password=secure_password_2024/' /tmp/complex-config.conf
sed -i 's/server/node/g' /tmp/complex-config.conf

cat /tmp/complex-config.conf

# --- Task 6: Cheat-sheets ---
cat > nano-cheatsheet.txt <<'EOF'
NANO QUICK REFERENCE
Ctrl+O : Save file
Ctrl+X : Exit
Ctrl+K : Cut line
Ctrl+U : Paste
Ctrl+W : Search
Ctrl+A : Beginning of line
Ctrl+E : End of line
Ctrl+Y : Page up
Ctrl+V : Page down
EOF

cat > vim-cheatsheet.txt <<'EOF'
VIM QUICK REFERENCE
MODES:
  i : Insert mode
  Esc : Normal mode
  :  : Command mode
NAVIGATION:
  h j k l : Left Down Up Right
  w : Next word
  b : Previous word
  0 : Line start
  $ : Line end
  gg : First line
  G : Last line
EDITING:
  x : Delete character
  dd: Delete line
  yy: Copy line
  p : Paste
  u : Undo
  Ctrl+r : Redo
SAVE/EXIT:
  :w  : Save
  :q  : Quit
  :wq : Save & quit
  :q! : Quit without saving
EOF

# --- Verification ---
ls -la ~/text-editor-lab/
test -s ~/text-editor-lab/server-config.txt
test -s ~/text-editor-lab/network-settings.conf
test -s /tmp/complex-config.conf

echo "Lab 6 - Working with vim and nano completed successfully!"
