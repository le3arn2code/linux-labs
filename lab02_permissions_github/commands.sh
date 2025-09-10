#!/usr/bin/env bash
# Lab 2: File Permissions and Executables — Commands
set -euo pipefail

# Create script
cat > myscript.sh << 'EOF'
#!/bin/bash
echo "Hello from myscript!"
EOF

# Check initial permissions
ls -l myscript.sh

# Add execute permission
chmod +x myscript.sh
ls -l myscript.sh

# Run script
./myscript.sh

# Change permissions
chmod 744 myscript.sh
ls -l myscript.sh

chmod 700 myscript.sh
ls -l myscript.sh

echo "Lab 2 - File Permissions and Executables completed successfully!"
