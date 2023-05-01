# SNMP_Exporter Readme

This has been configured for a Synology NAS.
Use the docker compose file to create the volumes and container.

## Prerequisites

Have a prometheus container installed and running.

Turn on SNMP in the Synology NAS and set up a username and password.

## Installation of SNMP_Exporter

1) Create the NFS folder on the NAS and copy in the snmp.yml configuration.

2) Edit the prometheus.yml configuration file to un-comment the SNMP job.

3) Copy the docker-compose volume and service into the "prometheus" stack Web editor.

4) Re-deploy the stack, restart prometheus, and check that it is running:

	a) Go to port 9090 on the server

	b) Click Status -> Targets

There should be a target called "snmp_exporter" and an endpoint with the NAS as the target in the "Up" state.

## Installation of Dashboard

Under the Grafana boilerplate there is an example dashboard for viewing the Synology NAS data.
This dashboard is also available on the Grafana template website.

https://grafana.com/grafana/dashboards/18643-synology-snmp/