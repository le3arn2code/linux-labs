# Lab 8: Installing and Managing Software Packages

> **No deviations** — this README summarizes exactly what was done in the lab.

## Objectives
- Install software using **dnf** and **yum**.
- Query and search packages with **rpm** and **dnf**.
- Remove unwanted packages and update existing ones.
- Understand managers (dnf, yum, rpm) and their use cases.
- Handle dependencies and resolve conflicts.
- Verify package integrity and installation status.

## Prerequisites
- RHEL 8/9 or CentOS Stream instance with sudo access and internet connectivity.
- Package tools preinstalled (as per lab environment).

## Tasks Covered
1. **Identify available package managers** (`which dnf`, `which yum`, versions).
2. **Update repository metadata** (`sudo dnf update` / `sudo yum update`).
3. **Install packages**: nano, htop, wget; multiple (tree, unzip, zip, curl); groups (“Development Tools”).
4. **Query packages (rpm & dnf)**: list, info, files, owners, provides, deps, updates, history, repos.
5. **Remove & update**: remove single package, autoremove orphans, update specific/all, reinstall, downgrade (if needed), clean cache.
6. **Practical scenario**: Web dev stack (httpd, php, php-mysql, mariadb-server, git) — start/enable httpd, verify, update, optional cleanup.
7. **Troubleshooting**: not found, deps, disk, repo; verification commands.

## Troubleshooting (from the lab)
- **Package not found**
  - `sudo dnf update`
  - `dnf search <name>`
  - `dnf repolist`
- **Dependency conflicts**
  - `sudo dnf install <pkg> --best --allowerasing`
  - Or `--skip-broken` (use carefully)
- **Disk space issues**
  - `df -h`
  - `sudo dnf clean all`
  - `sudo dnf autoremove -y`
- **Repository issues**
  - `ping google.com`
  - `sudo dnf clean metadata && sudo dnf update`

## Verification
```bash
rpm -q nano htop wget curl
dnf --version && rpm --version
dnf check-update | head -5
dnf repolist enabled
```

## Outcome
- Installed, queried, updated, and removed packages with **dnf/yum/rpm**.
- Resolved dependencies and cleaned caches.
- Built a small web dev stack and validated services.
- Documented troubleshooting and verification steps.

---
