#!/bin/bash
# Lab 6 Commands: vim and nano

# Setup
mkdir ~/text-editor-lab
cd ~/text-editor-lab
which vim
which nano
vim --version | head -1
nano --version | head -1

# Nano usage
nano server-config.txt
ls -la server-config.txt
cat server-config.txt
nano server-config.txt  # reopen and modify

# Vim usage
vim network-settings.conf
ls -la network-settings.conf
cat network-settings.conf
vim network-settings.conf

# Comparison
nano comparison-nano.txt
vim comparison-vim.txt
cat comparison-nano.txt
echo "---"
cat comparison-vim.txt

# Practical
nano /tmp/httpd.conf
vim /tmp/complex-config.conf
cat /tmp/complex-config.conf

# Cheat Sheets
nano nano-cheatsheet.txt
vim vim-cheatsheet.txt
