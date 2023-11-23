# Bind9

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For Bind9, I like to set this up on a macvlan. This gives a static IP on my home network.

There are three reasons for this:

1) The default port for DNS and Bind9 is 53 and this can conflict with other services such as the Ubuntu localhost DNS

2) Having a static IP means I can add a local DNS record on my home network (although in Bind case it is the DNS)

3) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier (not relevant for Bind9)

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

This can be an issue for containers such as Bind9 if you need to access the host, so you may wish to add multiple networks.
I also connect Bind9 to my Prometheus Bridge network for scraping data and reporting in Grafana.

I also prefer to use NFS Shared Folders on my Synology NAS to store any persistent data. This way it can be backed up using HyperBackup.

> :warning: Note: you may have to set up the Squash as "No Mapping".
On a Synology NAS this is done at the Shared Folder level in Control Panel.

Please note, using a Squash with No Mapping will mean that files cannot be edited directly from the NAS. 
You can enable SSH for the Synology, remote in, and use sudo nano (or alternative editor) to edit the config files.
My preference is to keep SSH turned off on the Synology NAS though, so I edit the files by bashing into the container directly.

## Installation of Bind9

1) Create the NFS folder on the NAS

	a) Open the Synology DSM web interface.
	
	b) Go to "Control Panel" > "File Services" > "NFS".
	
	c) Ensure NFS is enabled or click Enable NFS service, select NFS 4.0 or higher, and click "Apply".
	
	d) Go to "Control Panel" > "Shared Folder".
	
	e) Click "Create" to add a new shared folder.
	
	f) Set the folder path and name.
	
	g) Click "NFS Permissions" and set the permissions for the folder.
	
	h) Set the NFS Hostname to the Docker Server Host (not macvlan), host access to "Read/Write", squash to "Map all users to admin", select "Enable asynchronous" and "Allow users to access mounted subfolders", and finally click "Save".

2) Create a new stack in Portainer, name it "bind9" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

3) Deploy the stack and check that it is running.

4) Update the default configuration files.

	:warning: Note: by default, the file permissions are set with the bind user as owner.
	One way I've found is easiest is to install nano on the container and edit the files directly.
	
	a) Replace the code in named.conf.options, remembering to include the acl for security.
	
	b) Update the named.conf.local to include any zones required.
	
	c) Create the zone.[namespace] file and update as required (example provided).

5) Test the configuration.

	a) Open a terminal on your personal computer and run an nslookup, making sure to reference the assigned IP address.
	It should return a Non-authoritative answer successfully.

	```
	 nslookup youtube.com 10.0.2.10
	 ```

	 b) Run the same test but for one of the custom zones that have been created.
	
	```
	 nslookup custom.dns 10.0.2.10
	 ```