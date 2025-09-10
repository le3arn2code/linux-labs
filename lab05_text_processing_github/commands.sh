#!/usr/bin/env bash
# Lab 5: Text Processing with grep, sed, and awk — Commands
set -euo pipefail

# Create working directory and datasets
mkdir -p ~/text_processing_lab
cd ~/text_processing_lab

cat > employees.txt << 'EOF'
John Smith,Manager,Sales,75000
Jane Doe,Developer,IT,65000
Mike Johnson,Analyst,Finance,55000
Sarah Wilson,Manager,IT,80000
Tom Brown,Developer,IT,60000
Lisa Davis,Analyst,Sales,50000
Robert Taylor,Manager,Finance,85000
Emily White,Developer,IT,62000
David Lee,Analyst,IT,58000
Maria Garcia,Manager,Sales,78000
EOF

cat > server_logs.txt << 'EOF'
2024-01-15 10:30:15 INFO: Server started successfully
2024-01-15 10:31:22 ERROR: Database connection failed
2024-01-15 10:32:10 WARNING: High memory usage detected
2024-01-15 10:33:45 INFO: User login: admin
2024-01-15 10:34:12 ERROR: File not found: /var/log/app.log
2024-01-15 10:35:30 INFO: Backup process completed
2024-01-15 10:36:18 WARNING: Disk space low
2024-01-15 10:37:25 ERROR: Network timeout occurred
2024-01-15 10:38:40 INFO: User logout: admin
2024-01-15 10:39:55 INFO: System maintenance scheduled
EOF

cat > products.txt << 'EOF'
Laptop,Electronics,999.99,50
Mouse,Electronics,29.99,200
Keyboard,Electronics,79.99,150
Chair,Furniture,299.99,25
Desk,Furniture,499.99,15
Monitor,Electronics,399.99,75
Headphones,Electronics,149.99,100
Lamp,Furniture,89.99,40
Notebook,Office,12.99,500
Pen,Office,2.99,1000
EOF

# --- grep basics ---
grep "Manager" employees.txt
grep -i "manager" employees.txt
grep -c "IT" employees.txt
grep -n "Developer" employees.txt
grep -v "IT" employees.txt

# --- grep with regex/recursive ---
grep "^2024-01-15 10:3[0-5]" server_logs.txt
grep "000$" employees.txt || true
grep "[0-9]" products.txt
grep -E "(ERROR|WARNING)" server_logs.txt
mkdir -p logs && cp server_logs.txt logs/
grep -r "ERROR" .

# Practical grep
grep -E ",[7-9][0-9][0-9][0-9][0-9]$" employees.txt
grep "Electronics" products.txt
grep "10:3[0-5]" server_logs.txt
grep "IT" employees.txt | grep "Manager"

# --- sed basics ---
sed 's/IT/Information Technology/' employees.txt
sed 's/IT/Information Technology/g' employees.txt
sed 's/IT/Information Technology/g' employees.txt > employees_updated.txt
cp employees.txt employees_backup.txt
sed -i 's/IT/Information Technology/g' employees_backup.txt
cat employees_backup.txt

# Advanced sed
sed '2d' employees.txt
sed '/Manager/d' employees.txt
sed '1i\Employee Database Report' employees.txt
sed '$a\End of Report' employees.txt
sed '3s/Analyst/Senior Analyst/' employees.txt
sed '/Finance/s/Analyst/Senior Analyst/' employees.txt

sed -e 's/IT/Information Technology/g' -e 's/Manager/Director/g' employees.txt
sed 's/[0-9][0-9][0-9][0-9][0-9]/SALARY_HIDDEN/g' employees.txt
sed 's/ERROR:/[ERROR]:/g; s/WARNING:/[WARNING]:/g; s/INFO:/[INFO]:/' server_logs.txt
sed 's/.*,\([^,]*\),\([^,]*\),.*/Department: \2, Role: \1/' employees.txt

# Practical sed
sed -e '1i\=== EMPLOYEE REPORT ===' -e 's/,/ | /g' -e '$a\=== END OF REPORT ===' employees.txt
sed -e 's/2024-01-15 //' -e 's/INFO:/[INFO]/' -e 's/ERROR:/[ERROR]/' -e 's/WARNING:/[WARN]/' server_logs.txt
sed 's/,/|/g' products.txt

# --- awk basics ---
awk -F',' '{print $1}' employees.txt
awk -F',' '{print $1, $2}' employees.txt
awk -F',' '{print "Name: " $1 ", Position: " $2}' employees.txt
awk -F',' '{print NR ": " $1}' employees.txt
awk 'END {print "Total employees: " NR}' employees.txt

# awk with conditions/patterns
awk -F',' '$2 == "Manager" {print $1, $4}' employees.txt
awk -F',' '$4 > 60000 {print $1, $4}' employees.txt
awk -F',' '$3 == "IT" {print $1, $2}' employees.txt
awk -F',' '{dept[$3]++} END {for (d in dept) print d, dept[d]}' employees.txt

# Advanced awk script
cat > employee_analysis.awk << 'EOF'
BEGIN {
    FS = ","
    print "=== EMPLOYEE ANALYSIS REPORT ==="
    print "================================="
    total_salary = 0
    employee_count = 0
}
{
    dept[$3]++
    position[$2]++
    total_salary += $4
    employee_count++
    if ($4 > max_salary) {
        max_salary = $4
        highest_paid = $1
    }
}
END {
    print "\nDEPARTMENT BREAKDOWN:"
    for (d in dept) {
        printf "%-15s: %d employees\n", d, dept[d]
    }
    print "\nPOSITION BREAKDOWN:"
    for (p in position) {
        printf "%-15s: %d employees\n", p, position[p]
    }
    print "\nSALARY STATISTICS:"
    printf "Total Employees: %d\n", employee_count
    printf "Total Salary: $%.2f\n", total_salary
    printf "Average Salary: $%.2f\n", total_salary/employee_count
    printf "Highest Paid: %s ($%.2f)\n", highest_paid, max_salary
    print "\n=== END OF REPORT ==="
}
EOF

awk -f employee_analysis.awk employees.txt

# awk for log analysis
awk '{
    if ($3 == "ERROR:") errors++
    else if ($3 == "WARNING:") warnings++
    else if ($3 == "INFO:") info++
    logs[NR] = $0
}
END {
    print "=== LOG ANALYSIS ==="
    print "INFO entries:", info
    print "WARNING entries:", warnings
    print "ERROR entries:", errors
    print "Total entries:", NR
    if (errors > 0) {
        print "\nERROR DETAILS:"
        for (i=1; i<=NR; i++) if (logs[i] ~ /ERROR:/) print logs[i]
    }
}' server_logs.txt

# awk for product data
awk -F',' '
BEGIN {
    print "=== INVENTORY REPORT ==="
    total_value = 0
}
{
    product_value = $3 * $4
    total_value += product_value
    printf "%-15s: $%8.2f x %3d = $%10.2f\n", $1, $3, $4, product_value
    category_value[$2] += product_value
    category_count[$2] += $4
}
END {
    print "\n=== CATEGORY SUMMARY ==="
    for (cat in category_value) {
        printf "%-15s: %3d items, Total Value: $%10.2f\n", cat, category_count[cat], category_value[cat]
    }
    printf "\nGRAND TOTAL INVENTORY VALUE: $%.2f\n", total_value
}' products.txt

# --- Pipelines combining tools ---
grep "IT" employees.txt | sed 's/IT/Information Technology/g' | awk -F',' '{print $1 " works in " $3 " earning $" $4}'
grep -E "(ERROR|WARNING)" server_logs.txt | sed 's/2024-01-15 //' | awk '{print "Alert at " $1 ": " substr($0, index($0,$2))}'
grep "Electronics" products.txt | awk -F',' '{total += $3 * $4; count++} END {print "Electronics inventory value: $" total " (" count " items)"}'

# Comprehensive processing script
cat > process_data.sh << 'EOF'
#!/bin/bash
echo "=== COMPREHENSIVE DATA PROCESSING REPORT ==="
echo "Generated on: $(date)"
echo "=============================================="
echo -e "\n1. HIGH-VALUE EMPLOYEES (Salary > 70000):"
grep -E ",[7-9][0-9][0-9][0-9][0-9]$" employees.txt | sed 's/,/ | /g' | awk '{print "   " $0}'
echo -e "\n2. IT DEPARTMENT ANALYSIS:"
grep "IT" employees.txt | awk -F',' '{
    total += $4; count++;
    if ($2 == "Manager") managers++;
    else if ($2 == "Developer") developers++;
    else analysts++;
}
END {
    print "   Total IT employees: " count
    print "   Managers: " managers
    print "   Developers: " developers
    print "   Analysts: " analysts
    print "   Average IT salary: $" total/count
}'
echo -e "\n3. CRITICAL LOG ENTRIES:"
grep "ERROR" server_logs.txt | sed 's/ERROR:/[CRITICAL ERROR]/' | awk '{print "   " $0}'
echo -e "\n4. ELECTRONICS INVENTORY:"
grep "Electronics" products.txt | awk -F',' '{
    value = $3 * $4; total_value += value; total_items += $4;
    printf "   %-15s: $%7.2f x %3d = $%8.2f\n", $1, $3, $4, value
}
END {
    print "   ----------------------------------------"
    printf "   %-15s: %3d items = $%8.2f\n", "TOTAL", total_items, total_value
}'
echo -e "\n=============================================="
echo "Report completed successfully!"
EOF
chmod +x process_data.sh
./process_data.sh

# System admin scenario
cat > system_monitor.sh << 'EOF'
#!/bin/bash
cat > system_status.log << 'SYSEOF'
2024-01-15 10:30:00 CPU: 45% Memory: 67% Disk: 23%
2024-01-15 10:31:00 CPU: 52% Memory: 71% Disk: 23%
2024-01-15 10:32:00 CPU: 89% Memory: 78% Disk: 24%
2024-01-15 10:33:00 CPU: 34% Memory: 65% Disk: 24%
2024-01-15 10:34:00 CPU: 91% Memory: 82% Disk: 25%
2024-01-15 10:35:00 CPU: 28% Memory: 59% Disk: 25%
SYSEOF
echo "=== SYSTEM PERFORMANCE ANALYSIS ==="
echo "High CPU Usage (>80%):"
grep -E "CPU: [8-9][0-9]%" system_status.log | awk '{print "   " $1 " " $2 " - " $3}'
echo -e "\nHigh Memory Usage (>75%):"
grep -E "Memory: [7-9][0-9]%" system_status.log | awk '{print "   " $1 " " $2 " - " $4}'
echo -e "\nSystem Averages:"
awk '{
    gsub(/[CPU:Memory:Disk:%]/, "");
    cpu_total += $3; mem_total += $4; disk_total += $5; count++;
}
END {
    printf "   Average CPU: %.1f%%\n", cpu_total/count;
    printf "   Average Memory: %.1f%%\n", mem_total/count;
    printf "   Average Disk: %.1f%%\n", disk_total/count;
}' system_status.log
rm system_status.log
EOF
chmod +x system_monitor.sh
./system_monitor.sh

# Data cleaning example
cat > messy_data.txt << 'EOF'
  John Smith  ,  Manager  ,  Sales  ,  75000  
Jane Doe,Developer,IT,65000
  Mike Johnson,Analyst,Finance,55000
Sarah Wilson  ,Manager,IT,80000  
  Tom Brown,Developer  ,IT,60000
EOF

echo "=== DATA CLEANING EXAMPLE ==="
echo "Original messy data:"
cat messy_data.txt
echo -e "\nCleaned data:"
sed 's/^[ \t]*//; s/[ \t]*$//; s/[ \t]*,[ \t]*/,/g' messy_data.txt | \
awk -F',' '{printf "%-15s | %-10s | %-8s | $%s\n", $1, $2, $3, $4}'

# Verification
echo "IT employees count:"
grep -c "IT" employees.txt
echo "After replacing IT with Information Technology:"
sed 's/IT/Information Technology/g' employees.txt | grep -c "Information Technology"
echo "Average salary:"
awk -F',' '{total += $4; count++} END {print total/count}' employees.txt
echo "Highest paid employee:"
awk -F',' '{if ($4 > max) {max = $4; name = $1}} END {print name, max}' employees.txt

echo "Lab 5 - Text Processing with grep, sed, and awk completed successfully!"
