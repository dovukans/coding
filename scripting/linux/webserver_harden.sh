#!/bin/bash
# RHEL Web Server Security Hardening Script
# Usage: sudo ./webserver_harden.sh

# ---[ STRICT MODE ]---
set -euo pipefail
trap 'echo "[-] Error at line $LINENO. Check $LOGFILE"; exit 1' ERR

# ---[ LOGGING SETUP ]---
LOGFILE="/var/log/webserver_harden.log"
ERRORLOG="/var/log/webserver_harden_errors.log"
exec > >(tee -a "$LOGFILE") 2>&1
exec 2> >(tee -a "$ERRORLOG") >&2
echo -e "\n[+] $(date) - Starting Web Server Hardening"

# ---[ CHECK ROOT ]---
if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run as root. BYE." 
    exit 1
fi

# ---[ DETECT WEB SERVER ]---
detect_webserver() {
    if systemctl is-active --quiet httpd || systemctl is-active --quiet apache2; then
        WEBSERVER="apache"
        SERVERNAME="Apache"
        # Detect service name
        if systemctl is-active --quiet httpd; then
            SERVICE_NAME="httpd"
            CONFDIR="/etc/httpd/conf.d"
            MAINCONF="/etc/httpd/conf/httpd.conf"
        else
            SERVICE_NAME="apache2"
            CONFDIR="/etc/apache2/conf-enabled"
            MAINCONF="/etc/apache2/apache2.conf"
        fi
        # Detect SSL config file location
        if [ -f "/etc/httpd/conf.d/ssl.conf" ]; then
            SSLCONF="/etc/httpd/conf.d/ssl.conf"
        elif [ -f "/etc/httpd/conf/httpd-ssl.conf" ]; then
            SSLCONF="/etc/httpd/conf/httpd-ssl.conf"
        elif [ -f "/etc/apache2/sites-available/default-ssl.conf" ]; then
            SSLCONF="/etc/apache2/sites-available/default-ssl.conf"
        else
            echo "[!] No SSL configuration found for Apache"
            SSLCONF=""
        fi
    elif systemctl is-active --quiet nginx; then
        WEBSERVER="nginx"
        SERVICE_NAME="nginx"
        CONFDIR="/etc/nginx/conf.d"
        MAINCONF="/etc/nginx/nginx.conf"
        SERVERNAME="Nginx"
        SSLCONF="$MAINCONF"
    elif systemctl is-active --quiet lighttpd; then
        WEBSERVER="lighttpd"
        SERVICE_NAME="lighttpd"
        CONFDIR="/etc/lighttpd"
        MAINCONF="/etc/lighttpd/lighttpd.conf"
        SERVERNAME="Lighttpd"
        SSLCONF="$MAINCONF"
    else
        echo "[-] No active web server detected. Exiting."
        exit 1
    fi
    echo "[+] Detected running server: $SERVERNAME (service: $SERVICE_NAME)"
}

# ---[ BACKUP CONFIG ]---
backup_config() {
    echo "[+] Backing up configs..."
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="/etc/${WEBSERVER}_backup_${TIMESTAMP}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$CONFDIR" "$BACKUP_DIR"
    [ -f "$MAINCONF" ] && cp "$MAINCONF" "$BACKUP_DIR"
    [ -n "${SSLCONF:-}" ] && [ -f "$SSLCONF" ] && [ "$SSLCONF" != "$MAINCONF" ] && cp "$SSLCONF" "$BACKUP_DIR"
    echo "[+] Backup saved to: $BACKUP_DIR"
}

# ---[ HARDENING FUNCTIONS ]---
harden_apache() {
    echo "[+] Hardening Apache..."
    
    # TLS/SSL Hardening (only if SSL config exists)
    if [ -n "$SSLCONF" ] && [ -f "$SSLCONF" ]; then
        echo "[+] Applying TLS hardening to $SSLCONF"
        sed -i 's/SSLProtocol all -SSLv3/SSLProtocol TLSv1.2 TLSv1.3/g' "$SSLCONF" 2>/dev/null || echo "[!] Could not modify SSLProtocol in $SSLCONF"
        sed -i 's/SSLCipherSuite HIGH:!aNULL:!MD5/SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256/g' "$SSLCONF" 2>/dev/null || echo "[!] Could not modify SSLCipherSuite in $SSLCONF"
    else
        echo "[!] No SSL configuration found - skipping TLS hardening"
    fi

    # Basic Security
    sed -i 's/Options Indexes FollowSymLinks/Options -Indexes +FollowSymLinks/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not modify Options in $MAINCONF"
    grep -qxF 'ServerTokens Prod' "$MAINCONF" || echo 'ServerTokens Prod' >> "$MAINCONF"
    grep -qxF 'ServerSignature Off' "$MAINCONF" || echo 'ServerSignature Off' >> "$MAINCONF"
    grep -qxF 'TraceEnable off' "$MAINCONF" || echo 'TraceEnable off' >> "$MAINCONF"

    # Security Headers
    if ! grep -qxF 'Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"' "$MAINCONF"; then
        echo 'Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"' >> "$MAINCONF"
    fi
    
    # Balanced CSP Policy
    CSP_POLICY="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self';"
    if ! grep -qxF "Header always set Content-Security-Policy \"$CSP_POLICY\"" "$MAINCONF"; then
        echo "Header always set Content-Security-Policy \"$CSP_POLICY\"" >> "$MAINCONF"
        echo "[+] Set balanced CSP policy that allows common web patterns"
        echo "[!] NOTE: You may need to customize this further for your specific site:"
        echo "     Current policy: $CSP_POLICY"
        echo "     Edit $MAINCONF and search for 'Content-Security-Policy'"
    fi

    grep -qxF 'Header always set X-Content-Type-Options "nosniff"' "$MAINCONF" || echo 'Header always set X-Content-Type-Options "nosniff"' >> "$MAINCONF"
    grep -qxF 'Header always set X-Frame-Options "SAMEORIGIN"' "$MAINCONF" || echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> "$MAINCONF"

    # Cleanup
    [ -d "/usr/share/httpd/noindex" ] && rm -rf /usr/share/httpd/noindex/*
    [ -d "/var/www/html" ] && find /var/www/html -type d -exec chmod 750 {} \; && find /var/www/html -type f -exec chmod 640 {} \;

    # SELinux Hardening
    if sestatus | grep -q "SELinux status: disabled"; then
        echo "[-] SELinux is disabled, skipping SELinux hardening."
    else
        echo "[+] Hardening SELinux for Apache..."
        setsebool -P httpd_can_network_connect 0
        setsebool -P httpd_mod_auth_pam 0
    fi
}

harden_nginx() {
    echo "[+] Hardening Nginx..."
    
    # TLS/SSL Hardening
    sed -i 's/ssl_protocols TLSv1 TLSv1.1 TLSv1.2;/ssl_protocols TLSv1.2 TLSv1.3;/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not modify ssl_protocols in $MAINCONF"
    sed -i 's/ssl_prefer_server_ciphers off;/ssl_prefer_server_ciphers on;/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not modify ssl_prefer_server_ciphers in $MAINCONF"
    sed -i 's/# ssl_ciphers/ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not modify ssl_ciphers in $MAINCONF"

    # Basic Security
    grep -qxF 'server_tokens off;' "$MAINCONF" || echo 'server_tokens off;' >> "$MAINCONF"
    grep -qxF 'if ($request_method !~ ^(GET|HEAD|POST)$ ) { return 405; }' /etc/nginx/conf.d/security.conf || echo 'if ($request_method !~ ^(GET|HEAD|POST)$ ) { return 405; }' >> /etc/nginx/conf.d/security.conf

    # Security Headers
    grep -qxF 'add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";' "$MAINCONF" || echo 'add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";' >> "$MAINCONF"
    
    # Balanced CSP Policy
    NGINX_CSP="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self';"
    if ! grep -qxF "add_header Content-Security-Policy \"$NGINX_CSP\";" "$MAINCONF"; then
        echo "add_header Content-Security-Policy \"$NGINX_CSP\";" >> "$MAINCONF"
        echo "[+] Set balanced CSP policy that allows common web patterns"
        echo "[!] NOTE: You may need to customize this further for your specific site:"
        echo "     Current policy: $NGINX_CSP"
        echo "     Edit $MAINCONF and search for 'Content-Security-Policy'"
    fi

    grep -qxF 'add_header X-Content-Type-Options nosniff;' "$MAINCONF" || echo 'add_header X-Content-Type-Options nosniff;' >> "$MAINCONF"
    grep -qxF 'add_header X-Frame-Options SAMEORIGIN;' "$MAINCONF" || echo 'add_header X-Frame-Options SAMEORIGIN;' >> "$MAINCONF"

    # File permissions
    [ -d "/usr/share/nginx/html" ] && find /usr/share/nginx/html -type d -exec chmod 750 {} \; && find /usr/share/nginx/html -type f -exec chmod 640 {} \;

    # SELinux Hardening
    if sestatus | grep -q "SELinux status: disabled"; then
        echo "[-] SELinux is disabled, skipping SELinux hardening."
    else
        echo "[+] Hardening SELinux for Nginx..."
        setsebool -P httpd_can_network_connect 0
    fi
}

harden_lighttpd() {
    echo "[+] Hardening Lighttpd..."
    
    # TLS/SSL Hardening
    sed -i 's/ssl.use-sslv2 = \"enable\"/ssl.use-sslv2 = \"disable\"/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not disable SSLv2 in $MAINCONF"
    sed -i 's/ssl.use-sslv3 = \"enable\"/ssl.use-sslv3 = \"disable\"/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not disable SSLv3 in $MAINCONF"
    grep -qxF 'ssl.openssl.ssl-conf-cmd = ("Protocol" => "TLSv1.2, TLSv1.3")' "$MAINCONF" || echo 'ssl.openssl.ssl-conf-cmd = ("Protocol" => "TLSv1.2, TLSv1.3")' >> "$MAINCONF"

    # Basic Security
    sed -i 's/dir-listing.activate = \"enable\"/dir-listing.activate = \"disable\"/g' "$MAINCONF" 2>/dev/null || echo "[!] Could not disable directory listing in $MAINCONF"
    grep -qxF 'server.tag = "Secure Server"' "$MAINCONF" || echo 'server.tag = "Secure Server"' >> "$MAINCONF"

    # File permissions
    [ -d "/var/www/html" ] && find /var/www/html -type d -exec chmod 750 {} \; && find /var/www/html -type f -exec chmod 640 {} \;

    # SELinux Hardening
    if sestatus | grep -q "SELinux status: disabled"; then
        echo "[-] SELinux is disabled, skipping SELinux hardening."
    else
        echo "[+] Hardening SELinux for Lighttpd..."
        setsebool -P httpd_can_network_connect 0
    fi
}

# ---[ POST-HARDEN VERIFICATION ]---
verify_hardening() {
    echo "[+] Verifying hardening..."
    case $WEBSERVER in
        "apache" | "nginx")
            response_code=$(curl -sI localhost | head -n 1 | awk '{print $2}')
            if [ "$response_code" != "200" ]; then
                echo "[-] HTTP response code is $response_code (expected 200). Something may be wrong."
            fi
            curl -sI localhost | grep -q "Strict-Transport-Security" || echo "[-] HSTS header missing!"
            curl -sI localhost | grep -q "Content-Security-Policy" || echo "[-] CSP header missing!"
            ;;
        "lighttpd")
            curl -sI localhost | grep -q "Server: Secure Server" || echo "[-] Server tag not hidden!"
            ;;
    esac
    echo "[+] Hardening verification complete."
}

# ---[ MAIN EXECUTION ]---
detect_webserver
backup_config

case $WEBSERVER in
    "apache") harden_apache ;;
    "nginx") harden_nginx ;;
    "lighttpd") harden_lighttpd ;;
    *) echo "[-] Unsupported web server."; exit 1 ;;
esac

# ---[ VALIDATE CONFIG ]---
echo "[+] Validating $SERVERNAME configuration..."
case $WEBSERVER in
    "apache")
        if ! $SERVICE_NAME -t; then
            echo "[-] Apache config test failed!"
            exit 1
        fi
        ;;
    "nginx") nginx -t || { echo "[-] Nginx config test failed!"; exit 1; } ;;
    "lighttpd") lighttpd -t -f /etc/lighttpd/lighttpd.conf || { echo "[-] Lighttpd config test failed!"; exit 1; } ;;
esac

# ---[ RESTART SERVICE ]---
echo "[+] Restarting $SERVERNAME ($SERVICE_NAME)..."
if ! systemctl restart "$SERVICE_NAME"; then
    echo "[-] Failed to restart $SERVICE_NAME!"
    exit 1
fi

# ---[ Verify service is running ]---
echo "[+] Verifying $SERVERNAME is running..."
if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "[-] $SERVICE_NAME failed to start!"
    exit 1
fi
echo "[+] $SERVERNAME is running successfully"

verify_hardening

echo -e "\n[+] HARDENING COMPLETE. SERVER IS SECURE."
echo "[!] IMPORTANT NEXT STEPS:"
echo "    1. Test all website functionality"
echo "    2. Check browser console for any Content Security Policy violations"
echo "    3. Monitor logs for any issues at:"
echo "       - General logs: $LOGFILE"
echo "       - Error logs: $ERRORLOG"
echo "       - Web server logs: /var/log/$SERVICE_NAME/*"