#!/usr/bin/env bash
# Lab 4: File and Directory Permissions — Commands
set -euo pipefail

# Create working directory
mkdir -p ~/permissions_lab
cd ~/permissions_lab

# Create test files and directory
echo "This is a regular text file" > textfile.txt
echo "#!/bin/bash" > script.sh
echo "echo 'Hello World'" >> script.sh
mkdir testdir
ls -l

# --- chmod numeric notation ---
chmod 755 script.sh
ls -l script.sh

chmod 600 textfile.txt
ls -l textfile.txt

./script.sh

# --- chmod symbolic notation ---
chmod g+x,o+x script.sh
ls -l script.sh

chmod g-w textfile.txt
ls -l textfile.txt

chmod u+rw,g+r,o-rwx textfile.txt
ls -l textfile.txt

# --- Directory permissions ---
echo "Directory content" > testdir/file1.txt
echo "More content" > testdir/file2.txt

chmod -x testdir
ls -l

# Expect permission denied
(ls testdir || true)
(cd testdir || true)

chmod +x testdir
ls testdir

# --- Ownership changes ---
# Requires sudo
# sudo su -
# useradd testuser
# passwd testuser
# groupadd testgroup
# usermod -a -G testgroup testuser
# exit

ls -l ~/permissions_lab/
sudo chown testuser ~/permissions_lab/textfile.txt
ls -l ~/permissions_lab/textfile.txt

sudo chown testuser:testgroup ~/permissions_lab/script.sh
ls -l ~/permissions_lab/script.sh

sudo chown -R testuser:testgroup ~/permissions_lab/testdir
ls -l ~/permissions_lab/
ls -l ~/permissions_lab/testdir/

sudo chgrp student ~/permissions_lab/textfile.txt
ls -l ~/permissions_lab/textfile.txt

# --- ACL operations ---
which setfacl getfacl || true

echo "ACL test content" > acltest.txt
ls -l acltest.txt

getfacl acltest.txt

setfacl -m u:testuser:rw acltest.txt
getfacl acltest.txt
ls -l acltest.txt

setfacl -m g:testgroup:r acltest.txt
getfacl acltest.txt

setfacl -m d:u:testuser:rwx testdir
setfacl -m d:g:testgroup:rx testdir
getfacl testdir

echo "Testing default ACL" > testdir/newfile.txt
getfacl testdir/newfile.txt

setfacl -x u:testuser acltest.txt
getfacl acltest.txt

setfacl -b acltest.txt
getfacl acltest.txt
ls -l acltest.txt

setfacl -m u:testuser:rw,g:testgroup:r,o::--- acltest.txt
getfacl acltest.txt

# --- Verification script ---
cat > permission_test.sh << 'EOF'
#!/bin/bash
echo "=== Permission Testing Script ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo ""

echo "=== File Permissions ==="
ls -l *.txt *.sh 2>/dev/null

echo ""
echo "=== Directory Permissions ==="
ls -ld testdir

echo ""
echo "=== ACL Information ==="
echo "Files with ACLs:"
ls -l | grep "+" || true

echo ""
echo "=== Detailed ACL for acltest.txt ==="
getfacl acltest.txt 2>/dev/null

echo ""
echo "=== Testing file access ==="
if [ -r textfile.txt ]; then
    echo "✔ Can read textfile.txt"
else
    echo "✗ Cannot read textfile.txt"
fi

if [ -x script.sh ]; then
    echo "✔ Can execute script.sh"
else
    echo "✗ Cannot execute script.sh"
fi
EOF

chmod +x permission_test.sh
./permission_test.sh

echo "Lab 4 - File and Directory Permissions completed successfully!"
