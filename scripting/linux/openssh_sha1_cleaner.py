#!/usr/bin/env python3

import re
import os
import sys
from datetime import datetime

# ===== CONFIGURATION =====
TARGET_FILE = "/etc/crypto-policies/back-ends/openssh.config"  # CHANGE THIS
DRY_RUN = False                # Set to True for testing
SILENT_MODE = False            # Set to True for automation
LOG_FILE = "/var/log/openssh_sha1_cleaner.log"  # Hidden logging
# ========================

def log_to_file(message):
    """Robust logging with clean timestamps and auto-creation"""
    try:
        # Ensure log directory exists and file is writable
        os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
        if not os.path.exists(LOG_FILE):
            with open(LOG_FILE, 'w'):
                os.chmod(LOG_FILE, 0o644)  # rw-r--r--
        
        with open(LOG_FILE, 'a') as f:
            f.write(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}\n")
    except Exception as e:
        sys.stderr.write(f"LOGGING ERROR: {str(e)[:100]}\n")

def show(message):
    """Beautiful terminal output"""
    if not SILENT_MODE:
        print(message)

def remove_sha1():
    # Initialize logging
    log_to_file(f"=== Process started ===")
    log_to_file(f"Target: {TARGET_FILE}")
    log_to_file(f"Mode: {'DRY RUN' if DRY_RUN else 'LIVE'}{' (SILENT)' if SILENT_MODE else ''}")
    
    # Mode handling
    effective_dry_run = False if SILENT_MODE else DRY_RUN
    
    show(f"\n=== Analyzing {TARGET_FILE} ===")
    log_to_file("Starting file analysis")

    # Verify target file
    if not os.path.exists(TARGET_FILE):
        show(f"ERROR: File not found - {TARGET_FILE}")
        log_to_file("ERROR: Target file missing")
        sys.exit(1)

    # Read file content
    try:
        with open(TARGET_FILE, 'r') as f:
            original = f.read()
    except Exception as e:
        show(f"ERROR: Failed to read file - {e}")
        log_to_file(f"ERROR: File read failed - {e}")
        sys.exit(1)

    # Process algorithms
    removed_algorithms = []
    crypto_sections = ('Ciphers', 'MACs', 'KexAlgorithms',
                     'PubkeyAcceptedAlgorithms', 'CASignatureAlgorithms', 'HostKeyAlgorithms')
    
    output = []
    for line in original.splitlines():
        if not line.strip() or line.strip().startswith('#'):
            output.append(line)
            continue

        parts = line.split(maxsplit=1)
        if len(parts) > 1 and parts[0] in crypto_sections:
            kept_algorithms = []
            for algo in parts[1].split(','):
                algo = algo.strip()
                if re.search(r'(^|[^a-z])sha1([^a-z]|$)', algo, re.IGNORECASE):
                    removed_algorithms.append(algo)
                else:
                    kept_algorithms.append(algo)
            
            new_line = f"{parts[0]} {','.join(kept_algorithms)}" if kept_algorithms else parts[0]
            output.append(new_line)
        else:
            output.append(line)

    # Handle no changes
    if not removed_algorithms:
        show("\nNo SHA1 algorithms found.")
        log_to_file("No SHA1 algorithms detected")
        sys.exit(0)

    # Show results
    show(f"\n{len(removed_algorithms)} algorithms to remove:")
    for algo in removed_algorithms:
        show(f"- {algo}")
    log_to_file(f"Found {len(removed_algorithms)} algorithms to remove")

    # Dry run handling
    if effective_dry_run:
        show("\nDRY RUN: No changes will be made")
        log_to_file("Dry run completed")
        sys.exit(0)

    # Interactive confirmation
    if not SILENT_MODE:
        response = input("\nProceed with changes? [y/N]: ").lower()
        if response != 'y':
            show("Operation cancelled")
            log_to_file("User cancelled operation")
            sys.exit(0)

    # Create backup
    backup_path = f"{TARGET_FILE}.bk{datetime.now().strftime('%d%m%Y')}"
    try:
        with open(backup_path, 'w') as f:
            f.write(original)
        show(f"\nBackup created: {backup_path}")
        log_to_file(f"Backup saved to {backup_path}")
    except Exception as e:
        show(f"\nERROR: Backup failed - {e}")
        log_to_file(f"Backup failed - {e}")
        sys.exit(1)

    # Apply changes
    try:
        with open(TARGET_FILE, 'w') as f:
            f.write('\n'.join(output) + '\n')
        show("Changes applied successfully!")
        log_to_file("Configuration updated successfully")
    except Exception as e:
        show(f"\nERROR: Failed to write changes - {e}")
        log_to_file(f"Write failed - {e}")
        sys.exit(1)

if __name__ == "__main__":
    remove_sha1()