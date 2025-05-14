# 🧰 Sysadmin Script Toolbox

![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnu-bash&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-0078D7?logo=powershell&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=yellow)
![Ansible](https://img.shields.io/badge/Ansible-000000?&logo=Ansible&logoColor=ff0000)
![RedHat](https://img.shields.io/badge/RedHat-EE0000?logo=redhat&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)



Scripts for common configuration hardening and vulnerability mitigation tasks, plus automation tools to save time and reduce human error in daily sysadmin work, because why not?

## 🔧 What's in here?

This repo contains small, purpose-built Bash, Python and PowerShell scripts that:

- Automate common system hardening steps

- Echo what changes are being made for clarity

- Use dynamic values when possible (no hardcoded paths or users)

- Work on systems where you usually have to dig through manuals or Stack Overflow


## 💡 Why I made this

As a sysadmin, I found myself repeating the same manual configuration edits across different Linux distros and Windows servers.
So instead of fixing the same 10 things on 10 servers, I decided to script once, apply many — and share what I use.

These are the scripts I actually use in production environments.

## 📁 Structure

<pre>scripting/
├── linux/
│   ├── <a href="/scripting/linux/openssh_sha1_cleaner.py">openssh sha1 cleaner</a> (<a href="docs/linux/openssh_sha1_cleaner.md">usage</a>) 
│   ├── <a href="/scripting/linux/webserver_harden.sh">webserver hardener</a> (<a href="docs/linux/webserver_harden.md">usage</a>) 
│   └── ...
├── windows/
│   ├── <a href="/scripting/windows/ad-ou-explorer.ps1">active directory ou explorer</a> (<a href="docs/windows/ad-ou-explorer.md">usage</a>) 
│   ├── ...
│   └── ...
 </pre>

## ⚠️ Disclaimer

NEVER TEST IN PRODUCTION, EVER. YES I AM LOOKING AT YOU, BRAVE SOLDIER. DON'T DO IT.

## 📬 Want to suggest something?

Open an issue.
<br><br>

>  🍽️ **Bon appétit!** 
