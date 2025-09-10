# Lab 1: Introduction to the Bash Shell

This folder showcases my hands-on work for **Lab 1: Introduction to the Bash Shell**.

## Objectives
- Access and navigate the Linux command line interface using Bash.
- Execute fundamental Bash commands for file and directory operations.
- Understand and implement input/output redirection and piping techniques.
- Create, modify, and execute basic shell scripts.
- Apply command-line skills essential for Red Hat system administration (RHCSA).

## Prerequisites
- Basic understanding of file systems and directory structures.
- No prior Linux experience required.
- Access to a CentOS/RHEL-based cloud machine with Bash and standard utilities.

## Steps Performed

### 1. Access and Verify Shell
```bash
echo $SHELL
bash --version
whoami
date
```

### 2. Navigate the File System
```bash
pwd
ls
ls -l
ls -la
cd /
ls
cd ~
```

### 3. Manage Directories and Files
```bash
mkdir lab1-practice
cd lab1-practice
mkdir scripts documents backups
mkdir -p projects/web/html projects/web/css
ls -R

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
```

### 4. Copy, Move, Remove Files
```bash
cp welcome.txt documents/
cp welcome.txt welcome-backup.txt
mv readme.txt documents/
mv welcome-backup.txt welcome-copy.txt
rm welcome-copy.txt
ls
ls documents/
```

### 5. Redirection and Piping
```bash
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

ls /nonexistent-directory > output.txt 2> error.txt
ls /nonexistent-directory > combined.txt 2>&1
ls -la | tee directory-listing.txt
```

### 6. Shell Scripting
- **hello-world.sh**
- **system-report.sh**
- **user-info.sh** (interactive)
- **file-manager.sh**

Each script was created, made executable with `chmod +x`, and tested successfully.

## Troubleshooting Notes
- **Permission denied** → use `chmod +x script.sh`.
- **Command not found** → prefix with `./` if in the same directory.
- **Syntax errors** → use `bash -x script.sh` for debugging.

## Outcome
- Successfully executed core Bash commands.
- Practiced redirection, pipes, and script execution.
- Built multiple shell scripts demonstrating automation skills.

## Next Steps
- Move to user management, file permissions, and process control labs.
- Keep practicing Bash scripting for RHCSA readiness.

---
**Lab check:**  
```bash
echo "Lab 1 - Introduction to the Bash Shell completed successfully!"
```
