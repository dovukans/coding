# RHEL Web Server Security Hardening Script 

A robust Bash script to audit and harden common Linux web servers (Apache, Nginx, Lighttpd) with secure defaults and security headers.

>📄 **Index**
> - [webserver_harden.sh](../../scripting/linux/webserver_harden.sh) – Main hardening script
> - [README.md](./README.md) – You're here

## ✨ Features
- Automatic detection – Identifies running web servers (Apache/Nginx/Lighttpd)
- TLS/SSL hardening – Enforces modern protocols (TLS 1.2/1.3) and strong ciphers
- Security headers – Adds CSP, HSTS, XSS protection and other critical headers
- Balanced defaults – Safe CSP policies that work with common web patterns
- Backup system – Creates timestamped backups before any changes
- Validation system – Tests configurations before applying changes
- SELinux integration – Includes SELinux hardening where available

## 🖥 Supported Platforms


- RHEL, CentOS, AlmaLinux, Rocky Linux

- Requires: systemctl, bash, and root privileges

Tested On:

- RHEL 9.5 Server

- Apache 2.4.x

- Nginx 1.20+

## 🛠 What It Does
This script implements:
- TLS protocol hardening (disables SSLv3, TLS 1.0/1.1)
- Strong cipher suite enforcement
- Server information hiding
- Directory listing prevention
- Security headers (CSP, HSTS, X-Frame-Options)
- SELinux context hardening
- Safe defaults with audit capability

## 🚀 How to Use
``` 
sudo ./webserver_harden.sh
```
- Run as root or with sudo

- Automatically detects which web server is active and hardens it accordingly

- Creates timestamped backups of existing configs


## 🛡 Security Rationale

Modern threat models require strong defaults:

- Disabling SSLv3 and older TLS

- Removing weak ciphers (e.g., RC4, MD5, 3DES)

- Enforcing security headers against XSS and clickjacking

- Limiting HTTP method exposure

- Reducing default server exposure (ServerTokens, server_tokens)

This script eliminates the guesswork and ensures a minimal yet strong baseline.

## 🧠 Dev Notes

- Script must be executed with root privileges to edit config files and restart services

- Existing configs are never overwritten without backup

- Logs are stored at:

    - /var/log/webserver_harden.log (all actions)

    - /var/log/webserver_harden_errors.log (stderr only)

