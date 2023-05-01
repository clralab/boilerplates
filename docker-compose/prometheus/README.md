# Prometheus Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
This is important as Prometheus is not secure and should not be opened to the public.

The docker-compose file is set up to use a network called "bridge_prometheus". 

This can be created in Portainer or using the code below:

```
docker network create bridge_prometheus
```

I also prefer to keep all configuration files stored on my NAS.
This way I can easily access and update if required without having to terminal into the container.

Make sure to update the IP address and device in the vol_nfs_prometheus volume to match your configuration. 
Alternatively this can be changed to a local volume by removing the "driver_opts" section.
If you do this, it might be a good idea to change the volume name as well to remove the NFS reference.

Note that the data volumes are not created on the NFS share. 
This is because the data is only being held for 15 days as default. 
There is no need to back up the data, only the configuration.

## Installation of Prometheus

1) Create the NFS folder on the NAS and copy in the prometheus.yml configuration

2) Create a new stack in Portainer, name it "prometheus" and copy the docker-compose code into Web editor.

3) Deploy the stack and check that it is running:

	a) Go to port 9090 on the server
	b) Click Status -> Targets

There should be a target called "prometheus" and an endpoint localhost:9090/metrics in the "Up" state.

## Installation of Additional Targets

The following additional container examples are included in the configuration file:

- prometheus (stores scraped data)
- cadvisor (scrapes Docker containers)
- node_exporter (scrapes host statistics)
- nvidia_exporter (scrapes host GPU)
- snmp_exporter (example set up to scrape Synology NAS)

There are docker-compose boilerplates saved seperately. These can be added to the prometheus stack.

Grafana has been put in a seperate stack to keep the reporting stack seperate from the data.
A boilerplate is available for Grafana along with example dashboards that use the prometheus data.