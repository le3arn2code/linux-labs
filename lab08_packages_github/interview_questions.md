# Package Management — Interview Q&A (Top 10)

1) **DNF vs YUM vs RPM — when do you use each?**  
**Answer:** DNF/YUM are high‑level managers for resolving deps and transactions; DNF is default on RHEL 8+. RPM is the low‑level tool for querying/installing individual RPMs without dependency resolution.

2) **How do you find which package owns a file?**  
**Answer:** `rpm -qf /path/to/file` (installed file), or `dnf provides /path/to/file` to discover candidate packages.

3) **How do you list files installed by a package?**  
**Answer:** `rpm -ql <package>`.

4) **How do you search for packages by keyword vs by name?**  
**Answer:** `dnf search <keyword>` for descriptions/names; `dnf list <name>` or `dnf info <name>` for exact package details.

5) **What’s the safest way to update all packages?**  
**Answer:** `sudo dnf update -y` after reviewing `dnf check-update`, ideally during a maintenance window with backups/snapshots and change control.

6) **How do you clean up unused dependencies and caches?**  
**Answer:** `sudo dnf autoremove -y` removes orphans; `sudo dnf clean all` clears caches to free space.

7) **How do you troubleshoot “package not found”?**  
**Answer:** Refresh metadata (`sudo dnf update`), verify spelling, check enabled repos (`dnf repolist`) and add required repos (e.g., EPEL) if needed.

8) **How do you view dependency trees and resolve conflicts?**  
**Answer:** `dnf deplist <pkg>` to inspect deps; try `--best --allowerasing` to resolve conflicts (with caution) or use `--skip-broken` to proceed partially.

9) **How do you reinstall or downgrade a package?**  
**Answer:** Reinstall: `sudo dnf reinstall <pkg>`. Downgrade: `dnf list <pkg> --showduplicates` then `sudo dnf downgrade <pkg>-<version>` if available in repos.

10) **How do you audit recent package operations?**  
**Answer:** `dnf history list` and `dnf history info <ID>` show transaction history; `journalctl` can also contain relevant logs.
