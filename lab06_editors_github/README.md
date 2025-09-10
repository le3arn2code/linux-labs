# Lab 6: Working with vim and nano

This folder showcases my hands-on work for **Lab 6: Working with vim and nano**.

## Objectives
- Navigate and edit files using **vim** (modes, navigation, basic editing).
- Create, modify, and save files using **nano**.
- Understand differences and choose the right editor per scenario.
- Perform common text editing operations.
- Save and exit correctly in both editors.

## Prerequisites
- CentOS/RHEL-based Linux with **vim** and **nano** installed.
- Basic CLI skills (ls, cd, pwd, mkdir).
- Sudo access for writing to system-like locations (e.g., `/tmp`).

## Tasks Performed (Summary)
1. **Environment setup & editor checks** with `which vim`, `which nano`, version banners.
2. **nano workflow**: create `server-config.txt`, edit (cut/paste), save/exit, reopen and append Security settings.
3. **vim workflow**: create `network-settings.conf`, insert mode edits, yanking/pasting lines, save/quit with `:wq`, search, line numbers, goto, and substitution.
4. **Comparison**: write `comparison-nano.txt` and `comparison-vim.txt`.
5. **Practical scenarios**: quick web server config in nano (`/tmp/httpd.conf`); complex multi-service config in vim (`/tmp/complex-config.conf`) with change-operations and global substitution.
6. **Cheat-sheets** for nano and vim.
7. **Verification**: list files and cat key outputs.

> Note: In a scripted environment we use here-docs to **simulate** the content you typed in interactive editors so the repo is reproducible, but the README and `commands.sh` include the exact interactive key sequences you practiced.

## Troubleshooting Notes
- **Stuck in vim Insert mode** → Press `Esc` to return to Normal mode.
- **Can't exit vim** → `:q!` (discard) or `:wq` (save & quit) from Normal mode.
- **Accidental changes** → vim: `u` (undo), `Ctrl+r` (redo). nano: `Ctrl+X` then **N** to discard.
- **Where am I?** → vim: `:set number` shows line numbers; nano: `Ctrl+C` shows cursor position.
- **Files not saved** → nano: `Ctrl+O` then `Enter`; vim: `:w` or `:wq` from Normal mode.

## Outcome
- Confident with both editors: nano for fast edits, vim for powerful editing.
- Completed realistic configuration exercises and produced reproducible files.
- Included cheat-sheets for quick recall.

## Next Steps
- Learn vim motions and text-objects; explore `.vimrc` basics.
- Use nano `~/.nanorc` for syntax highlighting.
- Practice search/replace with regex across large files in vim.

---
**Lab check:**  
```bash
echo "Lab 6 - Working with vim and nano completed successfully!"
```
