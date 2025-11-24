#!/usr/share/env bash
#--------------------
# This script initiates directory for prometheus container volume with basic config, and clones spring-petclinic app to home directory

# Global settings
PROMETHEUS_DIR="/etc/prometheus"
PROMETHEUS_CONFIG="$PROMETHEUS_DIR/prometheus.yml"
SPRING_PETCLINIC_REPO="https://github.com/JustFiesta/spring-petclinic.git"
SPRING_PETCLINIC_DIR="spring-petclinic"

# Script - start

# Go to home directory
cd ~

# Create /etc/prometheus if not existing
if [ ! -d "$PROMETHEUS_DIR" ]; then
  echo "Tworzenie katalogu $PROMETHEUS_DIR..."
  sudo mkdir -p "$PROMETHEUS_DIR"
fi

# Craete prometheus.yml config file
echo "Tworzenie pliku konfiguracyjnego $PROMETHEUS_CONFIG..."
sudo tee "$PROMETHEUS_CONFIG" > /dev/null <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'spring-petclinic'
    static_configs:
      - targets: ['spring-petclinic:12345']
EOL

# Fetch repository
if [ ! -d "$SPRING_PETCLINIC_DIR" ]; then
  echo "Pobieranie repozytorium $SPRING_PETCLINIC_REPO..."
  git clone "$SPRING_PETCLINIC_REPO"
else
  echo "Repozytorium $SPRING_PETCLINIC_DIR już istnieje."
fi

echo "Setup completed successfully."
