# Prometheus + Grafana - Monitoring course

This repository contains my journey with Prometheus Monitoring tool.

The assesment was to create basic setup for spring-petlinic app and monitor it via JMX exporter.

<hr>

## What is Monitoring and Observability?

[Article about Monitorin and Observability](https://dora.dev/devops-capabilities/technical/monitoring-and-observability/)
[Monitoring Anti Patterns](https://docs.aws.amazon.com/wellarchitected/latest/devops-guidance/anti-patterns-for-continuous-monitoring.html) - there are more

## Service Discovery

Due to too much manual work engaged in adding new endpoints to monitor a Service Discovery tool is used for automated process.

Some of these services:
* Consul
* Zookeeper + Nerve
* Kubernetes (has its own Service Discovery)

## What is Prometheus?

Prometheus, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts when specified conditions are observed.

It fetches metrics as a strings, whitch can be printed and queried via PromQL and then made into charts in Prometheus UI.

It retrives data via pull based system (each target has exposed endpoint `/metrics` for Prometheus to use).

Also can alert teammembers via different channels. To do so it uses AlerManager.

[Prometheus doc](https://prometheus.io/docs/introduction/overview/)

[Prometheus architecture](https://www.youtube.com/watch?v=h4Sl21AKiDg&ab_channel=TechWorldwithNana)

[Basic configuration file - /etc/prometheus/prometheus.yml](https://prometheus.io/docs/prometheus/latest/getting_started/)

[AlerManager](https://prometheus.io/docs/alerting/latest/alertmanager/)

## Push vs Pull system

Each has its own advantages, for eg. 

* push is more resource hungry due to network load from custom push daemons
* pull might be harder to implement in enviromets with aggresive firewalls or complicated networks

[More on push vs pull](https://www.alibabacloud.com/blog/pull-or-push-how-to-select-monitoring-systems_599007)

### Metric Types

* Counters
* Gauges
* Histograms
* Summaries

[Metric types](https://prometheus.io/docs/tutorials/understanding_metric_types/)

### Exporters

Popular applications and systems are offically supported via *exporters*. This way one can integrate metrics from for eg. Linux systems, Database systems, Java applications (JMX exporter)

[Exporters/intergration with other tools](https://prometheus.io/docs/instrumenting/exporters/)
[JMX Exporter](https://github.com/prometheus/jmx_exporter)
[Sample usage of JMX Exporter](https://www.openlogic.com/blog/prometheus-java-monitoring-and-gathering-data)

### Libraries for custom applications

To monitor custom apps one needs to implement `/metrics` endpoint in application and create custom metrics for it.

[Supported libraries](https://prometheus.io/docs/instrumenting/clientlibs/)
[Example with nodejs app](https://blog.risingstack.com/node-js-performance-monitoring-with-prometheus/)

Examples of usage do build custom Counters, Gauges, Histograms and other are placed in repositories for each library.

## Monitor Containers

cAdvisor is used to monitor containers metrics. It automaticly checks container metrics. One also needs to add it to `prometheus.yml`

[More on cAdvisor](https://prometheus.io/docs/guides/cadvisor/)

## Alerts

Alerts divide into rules:

* [recoding rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
* [alerting rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

Each rules shloud be in separete file, and composed together in `prometheus.yml`, section `rule_files`

### Configuration of AlertManager

AlertManager is a part of Prometheus but can be installed sepparetly [Install Alertmanager binary](https://www.pluralsight.com/cloud-guru/labs/aws/installing-prometheus-alertmanager)
Configuration is stored in `/etc/alertmanager/alertmanager.yml`.

AlertManages uses `routes` for pushing metric alerts. One needs to create route for some `label` from roles and then use it in `recivers` section.

Also one needs to configure reciver. Many are supported out of the box. [More on recivers](https://prometheus.io/docs/alerting/latest/configuration/#receiver)

[AlertManager configuration](https://prometheus.io/docs/alerting/latest/configuration/)

[More on AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/)