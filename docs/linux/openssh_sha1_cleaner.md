 # OpenSSH SHA1 Cleaner 

A tiny but powerful script to automatically remove SHA1-based algorithms from OpenSSH crypto policy configs.

> **📄 Index**
>
> - [openssh_sha1_cleaner.py](../../scripting/linux/openssh_sha1_cleaner.py) – Main script
> - [README](./openssh_sha1_cleaner.md) – You're here


## ✨ Features

- Automated cleanup – Removes SHA1 algorithms from critical SSH configuration directives

- Safety-first design – Creates backups before modifications & supports dry-run previews

- Flexible execution – Silent mode for cron jobs/automation & verbose logging

- Self-contained – Zero external dependencies (just Python 3)

- Audit-ready – Generates timestamped logs of all actions

## 🖥 Supported Platforms

- Linux

- Tested On:

    - Red Hat Enterprise Linux 9.5 Server
    - OpenSSH_8.7p1

## 🖥 Supported Files

This script is designed to safely modify these common OpenSSH crypto-policy files when explicitly targeted:

- `/etc/crypto-policies/back-ends/openssh.config` 
- `/etc/crypto-policies/back-ends/opensshserver.config` 

How to use:

Set TARGET_FILE in the script to your specific config path

Always test with DRY_RUN=True first.

## 🛡 Security Rationale  

 SHA1 is considered **cryptographically broken** since 2017 ([NIST deprecation](https://csrc.nist.gov/Projects/Hash-Functions/NIST-Policy-on-Hash-Functions)). This script helps:  

- Eliminate vulnerable algorithms

- Enforce modern cryptographic baselines

- Avoid manual file editing errors

## 🔧 Configurable Options
Inside the script:

TARGET_FILE: Path to the OpenSSH crypto policy config

DRY_RUN: Preview mode

SILENT_MODE: Suppress all terminal output

LOG_FILE: Output path for logging

## 🧠 Dev Notes
The script is standalone, doesn't rely on any external dependencies. It can be dropped into any system where Python 3 is available. This script requires root privileges to run. Please execute it as root or with sudo.