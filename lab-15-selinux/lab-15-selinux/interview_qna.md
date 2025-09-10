# interview_qna.md — 10 SELinux Questions with Answers

### 1) How is SELinux different from traditional UNIX permissions?
**Answer:** Traditional permissions (DAC) allow resource owners to grant access. SELinux adds **mandatory access control (MAC)** that enforces system‑wide policy regardless of file ownership/permissions, reducing impact of compromised processes.

### 2) What are the common SELinux modes and when would you use each?
**Answer:** **Enforcing** (policy enforced) for production; **Permissive** (log only) for troubleshooting; **Disabled** only for edge cases where SELinux is unsupported—generally discouraged.

### 3) What is a *context* and which fields does it include?
**Answer:** A label attached to processes and objects (files, sockets). Typical format: `user:role:type:level`. The **type** (e.g., `httpd_t`, `httpd_sys_content_t`) is the key for Type Enforcement decisions.

### 4) Difference between `chcon` and `semanage fcontext` + `restorecon`?
**Answer:** `chcon` changes labels **immediately** but is not persistent (lost on relabel). `semanage fcontext -a ...` with `restorecon` makes a **persistent** rule so labels survive relabels and reboots.

### 5) What are SELinux booleans used for?
**Answer:** Toggles that enable/disable predefined policy allowances without custom modules, e.g., `httpd_can_network_connect`. Use `getsebool -a` to list and `setsebool -P` to persist.

### 6) How do you let Apache serve content from a non‑standard directory under `/home`?
**Answer:** Ensure files/dirs are labeled appropriately (often `httpd_sys_content_t`) using `semanage fcontext -a -t httpd_sys_content_t '/home/site(/.*)?' && restorecon -R`. Adjust booleans if needed (e.g., `httpd_read_user_content` on some systems).

### 7) When should you assign `httpd_exec_t` vs `httpd_sys_content_t`?
**Answer:** `httpd_exec_t` is for httpd **executables/modules**, not static web content; static content should be `httpd_sys_content_t`. Mislabeling can cause denials or excessive privileges.

### 8) How do you analyze what SELinux is blocking?
**Answer:** Check `/var/log/audit/audit.log` via `ausearch -m avc` and run `sealert -a /var/log/audit/audit.log` for human‑readable advice; generate targeted allows with `audit2allow` (review carefully).

### 9) How do you permit a service to bind to a non‑default port under SELinux?
**Answer:** Map the port to the appropriate type with `semanage port -a -t <type> -p <proto> <port>` (e.g., `http_port_t` for Apache), then configure the service and reload it.

### 10) What packages provide `semanage`, `sealert`, and `audit2allow` on RHEL 9?
**Answer:** `semanage` in `policycoreutils-python-utils`; `sealert` in `setroubleshoot-server`; `audit2allow` in `policycoreutils` (module build needs `checkpolicy`). Install via `dnf`.
