# Assessment

The assessment was to create basic setup for spring-petclinic app and monitor it via JMX exporter.

## Infrastructure

All is set up via `docker-compose`.

## Setup

1. Run the setup script to prepare directories and clone the repository:

    ```bash
    ./setup.sh
    ```

2. Start the containers:

    ```bash
    docker-compose up -d
    ```

## What's included

- **Spring PetClinic** - demo application running on port 8080, with JMX metrics exposed on port 12345
- **Prometheus** - monitoring system running on port 9090, configured to scrape metrics from the PetClinic app every 5 seconds

## Access

- PetClinic app: http://localhost:8080
- Prometheus dashboard: http://localhost:9090

## How it works

The setup script creates (on local machine) the Prometheus configuration directory and clones the Spring PetClinic repository.

They serve as config files for Docker Compose.

Docker Compose then builds and runs both services on a shared network, allowing Prometheus to collect JMX metrics from the application for monitoring.
