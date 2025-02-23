#!/bin/bash

# Detecting host IP address
host_ip=$(hostname -I | awk '{print $1}')

# Create users
useradd --no-create-home --shell /bin/false prometheus

# Create necessary directories and set permissions
mkdir -p /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and extract Prometheus
PROM_VERSION="2.54.1"
wget "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
tar -xzvf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
cp prometheus-${PROM_VERSION}.linux-amd64/{prometheus,promtool} /usr/local/bin/
cp -R prometheus-${PROM_VERSION}.linux-amd64/{consoles,console_libraries} /etc/prometheus/
chown -R prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus/consoles /etc/prometheus/console_libraries

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

# Display installation completion message
echo "Prometheus has been installed."



#!/bin/bash

# Create Node Exporter user
useradd --no-create-home --shell /bin/false node_exporter

# Download and set up Node Exporter
NODE_EXPORTER_VERSION="1.8.2"
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar -xzvf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

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

# Display completion message
echo "Node Exporter has been installed."
