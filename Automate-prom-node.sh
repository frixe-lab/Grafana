#!/bin/bash

set -e

# Log file for debugging
LOG_FILE="/var/log/prometheus_install.log"
exec > >(tee -a $LOG_FILE) 2>&1
echo "Installation started at $(date)"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Detecting host IP address
host_ip=$(hostname -I | awk '{print $1}')
if [ -z "$host_ip" ]; then
  echo "Failed to detect host IP. Please check your network configuration."
  exit 1
fi

# Variables for versions
PROM_VERSION="2.54.1"
NODE_EXPORTER_VERSION="1.8.2"

# Create users
useradd --no-create-home --shell /bin/false prometheus || true
useradd --no-create-home --shell /bin/false node_exporter || true

# Create directories and set permissions
mkdir -p /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and extract Prometheus
if [ ! -f "prometheus-${PROM_VERSION}.linux-amd64.tar.gz" ]; then
  wget "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
fi
tar -xzvf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
cp prometheus-${PROM_VERSION}.linux-amd64/{prometheus,promtool} /usr/local/bin/
cp -R prometheus-${PROM_VERSION}.linux-amd64/{consoles,console_libraries} /etc/prometheus/
chown -R prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus/consoles /etc/prometheus/console_libraries
rm -rf prometheus-${PROM_VERSION}.linux-amd64 prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Configure Prometheus with detected IP address
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['${host_ip}:17845']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['${host_ip}:1322']
EOF
chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create and configure Prometheus service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries --web.listen-address=:17845

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Prometheus service
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# Check Prometheus service status
if systemctl is-active --quiet prometheus; then
  echo "Prometheus is running."
else
  echo "Failed to start Prometheus. Check the logs for details."
  exit 1
fi

# Download and extract Node Exporter
if [ ! -f "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" ]; then
  wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
fi
tar -xzvf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Create and configure Node Exporter service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:1322

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Node Exporter service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Check Node Exporter service status
if systemctl is-active --quiet node_exporter; then
  echo "Node Exporter is running."
else
  echo "Failed to start Node Exporter. Check the logs for details."
  exit 1
fi

# Display installation completion message
echo "Installation of Prometheus and Node Exporter completed successfully."
