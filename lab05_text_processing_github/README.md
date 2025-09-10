# Lab 5: Text Processing with grep, sed, and awk

This folder showcases my hands-on work for **Lab 5: Text Processing with grep, sed, and awk**.

## Objectives
- Search text patterns with `grep` (basic/advanced regex, recursive search).
- Transform text with `sed` (substitution, deletion, insertion, multi-edit).
- Extract, manipulate, and report with `awk` (fields, conditions, scripts).
- Combine `grep`, `sed`, and `awk` in pipelines for real-world tasks.
- Practice regex-based processing on logs, CSVs, and structured text.

## Prerequisites
- Linux shell basics (cd, ls, cat).
- CentOS/RHEL-based environment with `grep`, `sed`, `awk` preinstalled.
- Familiarity with basic regex is helpful.

## Tasks Performed (Summary)
1. **Dataset creation**: `employees.txt`, `server_logs.txt`, `products.txt` in `~/text_processing_lab`.
2. **grep practice**: case-insensitive search, counts, line numbers, anchors (`^`, `$`), ERE (`-E`), recursion.
3. **sed practice**: single/global substitutions, delete/insert/append lines, multi-expression edits, formatting.
4. **awk practice**: fields, formatting, conditions/aggregations, full `employee_analysis.awk` report, log analysis, inventory reporting.
5. **Pipelines**: chained `grep | sed | awk` for combined analyses.
6. **Scripts**: `process_data.sh` (comprehensive report) and `system_monitor.sh` (simulated sys metrics), plus data cleaning example.
7. **Verification**: quick checks for counts, replacements, averages, and maxima.

## Troubleshooting Notes
- **grep finds nothing** → check case (`-i`), anchors (`^`, `$`), hidden characters (`cat -A file | head`).  
- **sed didn't change file** → use redirect (`> newfile`) or in-place flag (`-i[.bak]`), mind regex escaping.  
- **awk wrong columns** → ensure field separator with `-F','` (or multiple: `-F'[,|]'`).  
- **Regex issues** → try ERE (`grep -E`), escape metacharacters (e.g., `\$`, `\.`).

## Outcome
- Proficiency in `grep`, `sed`, `awk` for admin-grade text processing.
- Reusable AWK/SH scripts for reporting and log/inventory analysis.
- Verified results via pipeline outputs and verification commands.

## Next Steps
- Explore `grep -o`, `-A/-B/-C` context; `sed -n`, hold space; `awk` functions and external files.
- Apply to system logs in `/var/log` and automate via cron.

---
**Lab check:**  
```bash
echo "Lab 5 - Text Processing with grep, sed, and awk completed successfully!"
```
