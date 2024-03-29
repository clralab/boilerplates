# Cadvisor_Exporter Readme

Use the docker compose file to create the container.

> :warning: Note: the network must be set to Host to be able to scrape data

## Prerequisites

Have a prometheus container installed and running.

## Installation of Cadvisor_Exporter

1) Edit the prometheus.yml configuration file to un-comment the Cadvisor_Exporter job.

> :warning: Note: the IP address must be updated to the host IP

2) Copy the docker-compose service into the "prometheus" stack Web editor.

3) Re-deploy the stack, restart prometheus, and check that it is running:

	a) Go to port 9090 on the server
	b) Click Status -> Targets

There should be a target called "cadvisor_exporter" and an endpoint localhost:8080/metrics as the target in the "Up" state.

## Installation of Dashboard

Under the Grafana boilerplate there is an example dashboard for cadvisor.
This dashboard is also available on the Grafana template website.

## Shoutout and thanks

Special thanks to paaacman for the additional commands. These reduced my average Cadvisor CPU usage from 11.7% down to around 2.7%.

<a href="https://github.com/google/cadvisor/issues/2523">(Relatively) high CPU usage for the cadvisor container</a>