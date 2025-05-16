 ##### <a href="/README.md">← Back to home page</a>

# Monitoring Active Directory with Grafana, Prometheus, and Windows Exporter

This guide will walk you through setting up a full monitoring stack using:

- Grafana (visualization)

- Prometheus (metrics scraping and storage)

- Windows Exporter (metric exporter for Windows AD)

Tested on: Ubuntu Server (for Prometheus & Grafana) + Windows Server 2025 (for AD/Windows Exporter)

## 1. Install Grafana (on Ubuntu)
```
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana grafana-enterprise
```

After installation, start Grafana:
```
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```
You can now access Grafana at:

http://yourserverip:3000

- Default login:

    - Username: admin

    - Password: admin

You'll be prompted to set a new password on first login.

## 2. Install Prometheus (on Ubuntu)
```
sudo apt update
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v3.4.0-rc.0/prometheus-3.4.0-rc.0.linux-amd64.tar.gz
tar vxf prometheus*.tar.gz
cd prometheus*/
sudo mv prometheus /usr/local/bin
sudo mv promtool /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo mv consoles /etc/prometheus
sudo mv console_libraries /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
```
### Create Prometheus Systemd Service
```
sudo vi /etc/systemd/system/prometheus.service
```

Paste the following into the file:
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```
Start and enable the service:
```
sudo systemctl daemon-reexec
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

Verify it's running:

```
systemctl status prometheus
```

Allow port in firewall:
```
sudo ufw allow 9090/tcp
```

Prometheus is available at:

http://yourserverip:9090

## 3. Install Windows Exporter (on AD Server)

To expose metrics from your Active Directory server:

1. Go to windows_exporter releases (https://github.com/prometheus-community/windows_exporter/releases)

2. Download and run the installer on your AD server

3. During installation:

    - Enable all collectors by selecting [defaults]

    - Set the listening port to 9182

    - Complete the wizard

Make sure the service is running:
```
Get-Service windows_exporter
```

Also, open TCP port 9182 on the Windows firewall if needed.

## 4. Configure Prometheus to Scrape Metrics

Edit your Prometheus config:
```
sudo vi /etc/prometheus/prometheus.yml
```

Add the following scrape configs:

```
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
        labels:
          app: "prometheus"

  - job_name: "windows_ad"
    static_configs:
      - targets: ["<your-ad-server-ip>:9182"]
        labels:
          app: "windows_exporter"
```

Replace <your-ad-server-ip> with your actual AD server IP.

Restart Prometheus to apply changes:
```
sudo systemctl restart prometheus
```

Then visit:

http://yourprometheus-ip:9090/targets

You should see both jobs listed as UP.

## 5. Add Grafana Dashboard
- Open Grafana in your browser

- Login (admin / your password)

- Go to Dashboards > Import

- Enter Dashboard ID: 20763 (or any other Windows Exporter compatible ID)

- Select the Prometheus data source you configured

- Import

You’ll now see detailed Windows metrics (CPU, memory, services, disk, etc.) in a clean dashboard.

## ✅ Done

You’ve now successfully set up a complete monitoring stack for your Windows Active Directory environment using:

- Grafana for interactive dashboards

- Prometheus for collecting and storing metrics

- Windows Exporter for exposing Windows system metrics

- Prometheus server is scraping metrics from the AD and Grafana is visualizing those metrics in real time.

From here, you can:

- Customize or create new Grafana dashboards

- Set up alerting rules in Prometheus or Grafana (email, Slack, etc.)

- Monitor additional Windows servers by installing Windows Exporter on them and updating your Prometheus config

Thanks for reading the guide! If it helped you feel free to ⭐ the repo or share it with a teammate.