# Loki Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
This is important if the container is not secure and should not be opened to the public.

The docker-compose file is set up to use a network called "clra_bridge". 

This can be created in Portainer or using the code below:

```
docker network create clra_bridge
```

I also prefer to keep all configuration files stored on my NAS.
This way I can easily access and update if required without having to terminal into the container.

Make sure to update the IP address and device in the vol_nfs_loki volume to match your configuration.

## Installation of Loki

1) Create the NFS folder on the NAS and copy in the loki-config.yml configuration. 

2) Create a new stack in Portainer, name it "loki-promtail" and copy the docker-compose code into Web editor.

3) Copy in the docker-compose code for promtail.

3) Deploy the stack and check that it is running:

	a) Go to port 3100/metrics on the server
	b) Go to port 3100/ready on the server

There should be text saying "ready". If it says waiting 15 seconds, try refresh shortly.

## Installation of Additional Drivers

Docker driver must be installed to give access to Docker Container logs:

```
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
```

Update the Docker daemon /etc/docker/daemon.json. This file may or may not exist already.

```
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://localhost:3100/loki/api/v1/push",
    "loki-batch-size": "400"
  }
}
```