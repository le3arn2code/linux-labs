# Lab 6: Working with vim and nano

## Objectives
- Navigate and edit files using vim's basic commands and modes
- Create, modify, and save files using the nano text editor
- Understand the differences between vim and nano editors
- Perform common text editing operations in both editors
- Save and exit files properly in both vim and nano
- Choose the appropriate editor for different scenarios

## Tasks
1. Getting Started with Text Editors
2. Working with nano Editor
3. Working with vim Editor
4. Comparing vim and nano
5. Practical Scenarios (quick vs. complex edits)
6. Best Practices and Tips (when to use each editor)

## Troubleshooting
- **Stuck in vim insert mode** → Press `Esc` to return to Normal mode.
- **Can't exit vim** → Use `:wq` to save and quit, or `:q!` to quit without saving.
- **Accidentally modified file** → In vim: press `u` to undo; In nano: `Ctrl+X` then "No".
- **Lost in large file** → vim: `:set number`; nano: `Ctrl+C` shows position.

## Outcomes
- Mastered nano basics (create, edit, save, exit).
- Learned vim modes (Normal, Insert, Command).
- Compared vim vs. nano for different scenarios.
- Practiced configuration editing in both editors.
- Learned troubleshooting for common editor issues.

## Verification
```bash
ls -la ~/text-editor-lab/
cat ~/text-editor-lab/server-config.txt
cat ~/text-editor-lab/network-settings.conf
cat /tmp/complex-config.conf
```
