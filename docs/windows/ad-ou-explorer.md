# 🔍 AD Object Lister 
This PowerShell script allows administrators to interactively list and export Active Directory users, groups, or computers from a selected Organizational Unit (OU). It supports recursive searches, clear tabular output, and CSV export.

>📄 **Index**
> - [ad-ou-explorer.ps1](../../scripting/windows/ad-ou-explorer.ps1) – Main script
> - [README.md](./README.md) – You're here


## 🧰 Features
- Lists all OUs and lets you pick one by number.

- Option to include sub-OUs recursively.

- Lists:

    - ✅ Users (name, email, login info, etc.)

    - ✅ Groups (type, scope, description, member count)

    - ✅ Computers (OS, last logon, enabled status, etc.)

- Exports results to timestamped CSV (optional).



- No risk of accidental actions — read-only queries.

## ⚙️ Requirements
- PowerShell 5.1 or higher

- RSAT (Remote Server Administration Tools) with the ActiveDirectory module installed

- Permissions to read from Active Directory

## 🚀 How to Use
1- Open PowerShell as an administrator.

2- Run the script:
``` 
    .\AD-ObjectLister.ps1
```
3- Follow the prompts:

- Choose an Organizational Unit by number

- Select object type: user, group, or computer

- Choose whether to search sub-OUs

- Decide whether to export the results

## 📦 Example Output
```
Name             SamAccountName   EmailAddress         LastLogon           Department
----             --------------   ------------         ---------           ----------
Jane Doe         jdoe             jdoe@domain.com      4/28/2025 10:30 AM  Sales
John Smith       jsmith           jsmith@domain.com    5/12/2025 02:12 PM  Sales
```

## 📁 File Naming
CSV files are exported using this pattern:
```
<type>-list-<timestamp>.csv
e.g., user-list-20250514_183022.csv
```

## 🛡️ Dev Notes
- **This script does not modify any objects — it is safe for auditing and reporting.**

- Designed to be interactive, but can be easily adapted into a function with parameters for automation.