#!/usr/bin/env bash
# Lab 1: Introduction to the Bash Shell — Commands
set -euo pipefail

# Verify shell
echo $SHELL
bash --version
whoami
date

# Navigate
pwd
ls
ls -l
ls -la
cd /
ls
cd ~

# Directories
mkdir -p ~/lab1-practice/scripts ~/lab1-practice/documents ~/lab1-practice/backups
mkdir -p ~/lab1-practice/projects/web/html ~/lab1-practice/projects/web/css
ls -R ~/lab1-practice

# Files
cd ~/lab1-practice
touch readme.txt
echo "Welcome to Bash Shell Lab" > welcome.txt
cat welcome.txt

cat > system-info.txt << EOF
System Information Lab File
Created on: $(date)
User: $(whoami)
Directory: $(pwd)
EOF
cat system-info.txt

# Copy, move, remove
cp welcome.txt documents/
cp welcome.txt welcome-backup.txt
mv readme.txt documents/
mv welcome-backup.txt welcome-copy.txt
rm welcome-copy.txt
ls
ls documents/

# Redirection and pipes
ls -la > file-listing.txt
cat file-listing.txt
date >> file-listing.txt
echo "--- End of listing ---" >> file-listing.txt
cat file-listing.txt

cat > numbers.txt << EOF
10
25
5
30
15
EOF
sort < numbers.txt
sort < numbers.txt > sorted-numbers.txt

ls | wc -l
ps aux | grep bash
du -h | sort -hr
cat /etc/passwd | grep root
ls -la | grep "^d" | wc -l

ls /nonexistent-directory > output.txt 2> error.txt || true
ls /nonexistent-directory > combined.txt 2>&1 || true
ls -la | tee directory-listing.txt

echo "Lab 1 - Introduction to the Bash Shell completed successfully!"
