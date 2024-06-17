#!/usr/bin/env bash
#--------------------
# This script initiates directory for prometheus container volume with basic config, and clones spring-petclinic app to home directory

# Global settings
PROMETHEUS_DIR="/etc/prometheus"
PROMETHEUS_CONFIG="$PROMETHEUS_DIR/prometheus.yml"
LOKI_DIR="/etc/loki"
LOKI_CONFIG="$LOKI_DIR/loki-config.yaml"
PROMTAIL_DIR="/etc/promtail"
PROMTAIL_CONFIG="$PROMTAIL_DIR/promtail-config.yaml"
SPRING_PETCLINIC_REPO="https://github.com/JustFiesta/spring-petclinic.git"
SPRING_PETCLINIC_DIR="$HOME/spring-petclinic"
LOG_DIR="$HOME/log"

# Check if EC2_PUBLIC_IP is set
if [ -z "$EC2_PUBLIC_IP" ]; then
  echo "EC2_PUBLIC_IP is not set. Please set the EC2_PUBLIC_IP environment variable and try again."
  exit 1
fi

# Script - start

cat << EOF
"Please open these ports on host machine: 
    9080 	Promtail
    9090	Prometheus
    3100	Loki
    8080	Spring-petclinic app
    22	    SSH
    3000	Grafana
    12345	JMX exporter metrics"
EOF

# Go to home directory
cd ~

# Create /etc/prometheus if not existing
if [ ! -d "$PROMETHEUS_DIR" ]; then
  echo "Creating directory $PROMETHEUS_DIR..."
  sudo mkdir -p "$PROMETHEUS_DIR"
fi

# Create prometheus.yml config file
echo "Creating config file $PROMETHEUS_CONFIG..."
sudo tee "$PROMETHEUS_CONFIG" > /dev/null <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'spring-petclinic'
    scrape_interval: 5s
    static_configs:
      - targets: ['$EC2_PUBLIC_IP:12345']
EOL

# Create /etc/loki if not existing
if [ ! -d "$LOKI_DIR" ]; then
  echo "Creating directory $LOKI_DIR..."
  sudo mkdir -p "$LOKI_DIR"
fi

# Create loki-config.yaml config file
echo "Creating config file $LOKI_CONFIG..."
sudo tee "$LOKI_CONFIG" > /dev/null <<EOL
auth_enabled: false

server:
  http_listen_port: 3100

common:
  instance_addr: $EC2_PUBLIC_IP
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://$EC2_PUBLIC_IP:9093

reporting_enabled: false
EOL

# Create /etc/promtail if not existing
if [ ! -d "$PROMTAIL_DIR" ]; then
  echo "Creating directory $PROMTAIL_DIR..."
  sudo mkdir -p "$PROMTAIL_DIR"
fi

# Create promtail-config.yaml config file
echo "Creating config file $PROMTAIL_CONFIG..."
sudo tee "$PROMTAIL_CONFIG" > /dev/null <<EOL
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log
      stream: stdout
EOL

# Fetch repository
if [ ! -d "$SPRING_PETCLINIC_DIR" ]; then
  echo "Cloning repository $SPRING_PETCLINIC_REPO..."
  git clone "$SPRING_PETCLINIC_REPO"
else
  echo "Repository $SPRING_PETCLINIC_DIR already exists."
fi

# Create log directory if not existing
if [ ! -d "$LOG_DIR" ]; then
  mkdir "$LOG_DIR"
fi

# Build, run and get the Spring Petclinic application logs
cd "$SPRING_PETCLINIC_DIR"
./mvnw package
java -jar target/*.jar > "$LOG_DIR/spring-petclinic.log"

echo "Setup completed successfully."
