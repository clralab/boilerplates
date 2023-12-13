# Promtail Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
This is important as Promtail is not secure and should not be opened to the public.

The docker-compose file is set up to use a network called "clra_bridge". 

This can be created in Portainer or using the code below:

```
docker network create clra_bridge
```

I also prefer to keep all configuration files stored on my NAS.
This way I can easily access and update if required without having to terminal into the container.

Make sure to update the IP address and device in the vol_nfs_promtail volume to match your configuration. 
Alternatively this can be changed to a local volume.
If you do this, it might be a good idea to change the volume name as well to remove the NFS reference.

## Installation of Promtail

1) Create the NFS folder on the NAS and copy in the promtail-config.yml configuration

2) Create a new stack in Portainer, name it "loki-promtail" and copy the docker-compose code into Web editor.

3) Copy in the Loki docker-compose code into the stack.

4) Deploy the stack and check that it is running:

	a) Go to port 3100/ready on the server
	b) It should give a ready status, or wait 15 seconds and refresh to get the ready status

## Installation of Additional Targets

The following additional target examples are included in the configuration file:

- traefik (scrapes data from the log folder saved on the NFS Share)