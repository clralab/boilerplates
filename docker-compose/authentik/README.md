# Authentik Readme

Docker compose file for setting up authentik for Identity Management and SSO.

## Prerequisites

These installation instructions and compose file are dependant on having Traefik running and obtaining SSL certificates.

My personal preference is to isolate application stacks on their own networks.
Frontend applications are connected to a macvlan. This gives a static IP on my home network. 
Backend applications are connected to a bridge network. 

For authentik, I set up the Server on the frontend macvlan, and everything connects to the backend. 

There are a couple of reasons for this:

1) Having a static IP means I can add a local DNS record on my home network

2) Setting up a zero trust tunnel with a provider like Cloudflare, or reverse proxy with Traefik is a bit cleaner

A macvlan can be created using the following code (updated to include IPv6 support):

```
docker network create -d macvlan \
--subnet 10.0.2.0/24 --gateway 10.0.2.1 \
--subnet=2001:db8:cafe::/64 --gateway=2001:db8:cafe::1 \
-o parent=eno1 \
-o macvlan_mode=bridge \
--ipv6 \
clra_macvlan
```

Update according to your local network configuration. 
The parent can be found by running the ifconfig on the host.

> :warning: Note: macvlans are also isolated from the host as well (simple explaination). 
There is a great explaination on 
<a href="https://stackoverflow.com/questions/49600665/docker-macvlan-network-inside-container-is-not-reaching-to-its-own-host">Stackoverflow</a>
and also in the 
<a href="https://docs.docker.com/v17.09/engine/userguide/networking/get-started-macvlan/" rel="noreferrer" title="Docker Macvlan Documentation">Docker Macvlan Documentation</a>.

I also prefer to set up an NFS Share on my Synology NAS that will allow for backup of configuration files and persistent databases.
To do this:

1) Add a Shared Folder in the Control Panel App called nfs_docker_prod

2) Edit the NFS Permissions by selecting the folder, clicking edit, and then NFS Permissions

	a) Hostname or IP: 10.0.2.20 (the IP address of the Docker Server)
	
	b) Privilage: Read/Write
	
	c) Squash: No Mapping
	
	d) Security: sys
	
	e) Check: Enable asynchronous and Allow users to access mounted subfolders

> :warning: Note: Some Docker Containers require different a Squash setup such as Minecraft.
While most of my containers are set up under the Production NFS Folder, some containers require their own seperate Shared Folder to allow for different permissions.

## Installation of authentik

These installation instructions and compose file are dependant on having Traefik running and obtaining SSL certificates.

authentik uses Redis as a message-queue and a cache. 
Data in Redis is not required to be persistent, however you should be aware that restarting Redis will cause the loss of all sessions.
The Redis database does not have to be stored on the NAS as it doesn't need to be backed up.

1) Create the NFS folder on the NAS to store the persistent PostgresSQL database

2) Create a new stack in authentik, name it "authentik" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the network configuration backend and frontend IP address to a static IP outside your DHCP range
	
	c) update the Traefik router host rule
	
	d) add the environment variables from the .env file below the stack editor 

3) Deploy the stack and check that it is running:

	a) Go to the host defined in the Traefik router https://< router host >/if/flow/initial-setup/
	
	b) Set a password for the default akadmin user
	
	c) Create a new user

	d) Set up 2FA for the new user
	
	e) Elevate the new user to Administrator
	
	f) Deactivate the akadmin user  

## Application Setup

## Setup of Portainer SSO

TBC

## Setup of Synology DSM SSO

TBC

## Setup of Gitea SSO

TBC

## Setup of Grafana SSO

TBC
