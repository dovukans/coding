### Scripts for common configuration hardening & vulnerability mitigation tasks, written to save time and reduce human error in daily sysadmin tasks.

## 🔧 What's in here?

This repo contains small, purpose-built Bash and PowerShell scripts that:

-Automate common system hardening steps

-Echo what changes are being made for clarity

-Use dynamic values when possible (no hardcoded paths or users)

-Work on systems where you usually have to dig through manuals or Stack Overflow


## 💡 Why I made this

As a sysadmin, I found myself repeating the same manual configuration edits across different Linux distros and Windows servers.
So instead of fixing the same 10 things on 10 servers, I decided to script once, apply many — and share what I use.

These are the scripts I actually use in production environments.

## 📁 Structure

<pre> \`\`\` scripting/
├── linux/
│   ├── ...
│   ├── ...
│   └── ...
├── windows/
│   ├── ...
│   ├── ...
│   └── ...
\`\`\` </pre>

## ⚠️ Disclaimer

These scripts modify system configs — NEVER TEST IN PRODUCTION, EVER. YES I AM LOOKING AT YOU, BRAVE SOLDIER. DON'T DO IT.

📬 Want to suggest something?

Open an issue.
