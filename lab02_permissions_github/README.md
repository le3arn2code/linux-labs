# Lab 2: File Permissions and Executables

This folder showcases my hands-on work for **Lab 2: File Permissions and Executables**.

## Objectives
- Understand Linux file permissions (`rwx`) for user, group, and others.
- Learn to change permissions with `chmod`.
- Make scripts executable (`chmod +x`).
- Verify execution permissions and run scripts.

## Prerequisites
- A Linux system with Bash shell access.
- Basic knowledge of Lab 1 (navigating and creating files).

## Steps Performed

### 1. Create a Script
```bash
cat > myscript.sh << 'EOF'
#!/bin/bash
echo "Hello from myscript!"
EOF
```

### 2. Check Initial Permissions
```bash
ls -l myscript.sh
```

### 3. Add Execute Permission
```bash
chmod +x myscript.sh
ls -l myscript.sh
```

### 4. Run the Script
```bash
./myscript.sh
```

### 5. Change Permissions with Numeric Modes
```bash
chmod 744 myscript.sh   # user=rwx, group=r, others=r
chmod 700 myscript.sh   # only user can access
ls -l myscript.sh
```

## Troubleshooting Notes
- **Permission denied** → missing execute bit, fix with `chmod +x myscript.sh`.
- **Command not found** → prefix with `./` if in current directory.
- **Wrong mode** → verify with `ls -l` before executing.

## Outcome
- Successfully created a script and modified its permissions.
- Learned symbolic and numeric modes of `chmod`.
- Executed the script after making it runnable.

## Next Steps
- Explore ownership changes with `chown` and `chgrp`.
- Practice advanced permission bits (SUID, SGID, sticky bit).

---
**Lab check:**  
```bash
echo "Lab 2 - File Permissions and Executables completed successfully!"
```
