# Heimdall Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For Heimdall, I like to set this up on a macvlan. This gives a static IP on my home network.

There are three reasons for this:

1) The default port for Heimdall is 80 and this can conflict with other services

2) Having a static IP means I can add a local DNS record on my home network

3) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier

As many of the links are local, the third reason might not be as relevant for Heimdall.

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

While this can be an issue for containers such as Grafana that might need to access the host, this should not be an issue for Heimdall.

I also prefer to use NFS Shared Folders on my Synology NAS to store any persistent data. This way it can be backed up using HyperBackup.

> :warning: Note: you may have to set up the Squash as "No Mapping".
On a Synology NAS this is done at the Shared Folder level in Control Panel.

## Installation of Heimdall

1) Create the NFS folder on the NAS

	a) Open the Synology DSM web interface.
	
	b) Go to "Control Panel" > "File Services" > "NFS".
	
	c) Ensure NFS is enabled or click Enable NFS service, select NFS 4.0 or higher, and click "Apply".
	
	d) Go to "Control Panel" > "Shared Folder".
	
	e) Click "Create" to add a new shared folder.
	
	f) Set the folder path and name.
	
	g) Click "NFS Permissions" and set the permissions for the folder.
	
	h) Set the NFS Hostname to the Docker Server Host (not macvlan), host access to "Read/Write", squash to "Map all users to admin", select "Enable asynchronous" and "Allow users to access mounted subfolders", and finally click "Save".

2) Create a new stack in Portainer, name it "heimdall" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

4) Deploy the stack and check that it is running:

	a) Go to port 80 on the IP address updated in the stack 
	
	b) Start adding applications and links

## Optional Configuration

If you would like to change the name of the dashboard, this can be done by editing the dotenv file from the Container Console in Portainer.

1) Log into the console 

2) Navigate to config/www

3) Edit the dotenv file and change the "APP_NAME"