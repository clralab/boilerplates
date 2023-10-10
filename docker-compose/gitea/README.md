# Gitea Readme

Use the docker compose file to create the volumes and container.

This repository contains the code and instructions for setting up Gitea, a self-hosted Git service, on Docker. 

The instructions cover setting up a MariaDB database on a Synology NAS, creating a Gitea Docker container, and connecting it to the remote database and file volume. 

The code includes the Docker Compose file and any necessary configuration files. This is intended for those who want to self-host their Git service and have some knowledge of Docker and Synology NAS systems.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For Gitea, I like to set this up on a macvlan. This gives a static IP on my home network.

There are three reasons for this:

1) The default port for Gitea is 3000 and this can conflict with other services like Grafana

2) Having a static IP means I can add a local DNS record on my home network

3) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier

A macvlan can be created using the following code:

```
docker network create -d macvlan \
--subnet 192.168.1.0/24 \
--gateway 192.168.1.1 \
-o parent=eno1 \
clra_macvlan
```

Update according to your local network configuration. 
The parent can be found by running the ifconfig on the host.

> :warning: Note: macvlans are also isolated from the host as well (simple explaination). 
There is a great explaination on 
<a href="https://stackoverflow.com/questions/49600665/docker-macvlan-network-inside-container-is-not-reaching-to-its-own-host">Stackoverflow</a>
and also in the 
<a href="https://docs.docker.com/v17.09/engine/userguide/networking/get-started-macvlan/" rel="noreferrer" title="Docker Macvlan Documentation">Docker Macvlan Documentation</a>.

While this can be an issue for containers such as Grafana that might need to access the host, this should not be an issue for Gitea.

## Installation of Gitea

1) Create the NFS folder on the NAS

	a) Open the Synology DSM web interface.
	
	b) Go to "Control Panel" > "File Services" > "NFS".
	
	c) Ensure NFS is enabled or click Enable NFS service, select NFS 4.0 or higher, and click "Apply".
	
	d) Go to "Control Panel" > "Shared Folder".
	
	e) Click "Create" to add a new shared folder.
	
	f) Set the folder path and name.
	
	g) Click "NFS Permissions" and set the permissions for the folder.
	
	h) Set the NFS Hostname to the Docker Server Host (not macvlan), host access to "Read/Write", squash to "Map all users to admin", select "Enable asynchronous" and "Allow users to access mounted subfolders", and finally click "Save".

2) Create the database and user

	a) Install MariaDB on the Synology.
	
	b) Install and configure phpMyAdmin on the Synology.
	
	b) Create a new database with the "utf8_general_ci" collation.
	
	c) Create a new user with restricted access to the database.

3) Create a new stack in Portainer, name it "gitea" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

4) Deploy the stack and check that it is running:

	a) Go to port 3000 on the IP address updated in the stack 
	
	b) Follow the on-screen instructions to set up the Gitea administrator account.
	
	c) Select the database that was created in Step 2.
	
	d) Configure the email and server settings if necessary.

## Optional Configuration

> :warning: Note: if there is a need to edit the configuration file (conf/app.ini) directly, do not do this using the Synology GUI editor.
If you are able to use the Synology GUI editor to change the file, it will update the file owner details and can break Gitea.

As nano and vim are not available within the Gitea container, the easiest way I have found is to enable SSH on the Synology NAS and then edit the file using sudo nano.

If you are using a reverse proxy, such as a Cloudflare Tunnel, then you will need to allow this in the configuration file:

```
REVERSE_PROXY_LIMIT           = 1
REVERSE_PROXY_TRUSTED_PROXIES = *
```