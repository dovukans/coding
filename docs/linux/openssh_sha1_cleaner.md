 # OpenSSH SHA1 Cleaner 🔐

A tiny but powerful script to automatically remove SHA1-based algorithms from OpenSSH crypto policy configs.

## ✨ Features

- Detects and removes SHA1 algorithms from key SSH config directives
- Dry-run support to preview changes safely
- Silent mode for automated or cron-based execution
- Automatically creates log files with clean timestamps
- Creates a backup of the original config before making changes
- Designed to be plug-and-play on any machine

## 🖥 Supported Platforms

- Linux

## 🛡 Why remove SHA1?

SHA1 is deprecated due to known vulnerabilities and should not be used in cryptographic configurations. This script helps enforce a more secure baseline without manual editing.

## 🔧 Configurable Options
Inside the script:

TARGET_FILE: Path to the OpenSSH crypto policy config

DRY_RUN: Preview mode

SILENT_MODE: Suppress all terminal output

LOG_FILE: Output path for logging

## 🧠 Dev Notes
The script is standalone, doesn't rely on any external dependencies, and can be dropped into any system where Python 3 is available.