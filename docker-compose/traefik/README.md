# Traefik

Use the docker compose file to create the volumes and container.

## Prerequisites

### Networking

My personal preference is to isolate application stacks on their own networks.
For Traefik, I like to set this up on a macvlan. This gives a static IP on my home network.

There are three reasons for this:

1) The default port for the Traefik dashboard is 8080 and this can conflict with other services

2) Having a static IP means I can add a local DNS record on my home network (particularly important for adding catch-all records for Traefik)

3) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier (not relevant for Traefik though)

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

This can be an issue for containers such as Traefik that may try to access the host.

If containers are on multiple networks, such as Authentik on the front-end macvlan and back-end bridge, Traefik may try to connect to the bridge (host) from the macvlan (isolated) and result in a Bad Gateway error.

Thanks so much to <a href="https://community.traefik.io/t/docker-provider-how-does-traefik-choose-which-service-ip-address-to-proxy-to-when-container-is-on-multiple-networks/16852">candlerb</a> for figuring this out!

There are three ways I have found to fix this:

1) Add an explicit network in the traefik.yml file:

```
docker:
  exposedByDefault: false
  network: clra_macvlan
```

2) Add the Traefik container to both the front-end and back-end networks:

```
networks:
  clra_macvlan:
    external: true
  clra_bridge:
    external: true

services:
  traefik:
    networks:
      clra_macvlan:
        ipv4_address: 10.0.2.12
      clra_bridge:
```

3) Add an explicit network to the containers Traefik labels:

```
labels:
  - "traefik.enable=true"
	...
  - "traefik.docker.network=clra_macvlan"
```

Once a method has been set up, this can be tested by installing and using Curl from the Traefik console:

```
apk add --no-cache curl
curl -v http://<service ip><service port>
```


I have personally chosen to go with all of the options excluding a connection to the back-end. 
The benefit for me is using Traefik as a reverse proxy to route traffic from the internet.
There is no need, at this stage, for me to resolve, get an SSL certificate, and/or route traffic from the internet to my back-end services.
Or even my front-end services that I only plan to access when locally connected. Network config in the Traefik yml saves me from forgetting labels.

Access to services can be overly simply summarised as:

1) Front-end with access from the internet 

	a) Connected to Docker front-end network (and possibly back-end as well)

	b) Externally resolved with Cloudflare
	
	c) Internally resolved with Bind9
	
	d) SSL and routing through Traefik
	
	e) Secured through Authentik

2) Front-end internal only without access from the internet

	a) Connected to Docker front-end network (and possibly back-end as well) 

	b) Internally resolved with Bind9
	
	c) Only accessable if connected locally (or through VPN)
			
3) Back-end services

	b) Connected to the Docker back-end network only

### Volumes 

I also prefer to use NFS Shared Folders on my Synology NAS to store any persistent data. This way it can be backed up using HyperBackup.

> :warning: Note: you may have to set up the Squash as "No Mapping".
On a Synology NAS this is done at the Shared Folder level in Control Panel.

Please note, using a Squash with No Mapping will mean that files cannot be edited directly from the NAS. 
You can enable SSH for the Synology, remote in, and use sudo nano (or alternative editor) to edit the config files.
My preference is to keep SSH turned off on the Synology NAS though, so I edit the files by bashing into the container directly.

## Installation of Traefik

1) Create the NFS folder on the NAS

	a) Open the Synology DSM web interface.
	
	b) Go to "Control Panel" > "File Services" > "NFS".
	
	c) Ensure NFS is enabled or click Enable NFS service, select NFS 4.0 or higher, and click "Apply".
	
	d) Go to "Control Panel" > "Shared Folder".
	
	e) Click "Create" to add a new shared folder.
	
	f) Set the folder path and name.
	
	g) Click "NFS Permissions" and set the permissions for the folder.
	
	h) Set the NFS Hostname to the Docker Server Host (not macvlan), host access to "Read/Write", squash to "Map all users to admin", select "Enable asynchronous" and "Allow users to access mounted subfolders", and finally click "Save".

2) Create a new stack in Portainer, name it "traefik" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

3) Deploy the stack and check that it is running.

4) Update the default configuration files.

	:warning: Note: by default, the file permissions are set with the traefik user as owner.
	One way I've found is easiest is to sh into the container from Portainer and edit the files directly using vi.
	
	a) Edit the /etc/traefik/traefik.yaml file to meet your requirements (example provided).
	
	b) Edit the /etc/traefik/config.yaml file to meet your requirements (example for Synology DSM provided).
	
  c) Update your DNS records (I use CloudFlare globally and Bind9 locally)

5) Test the configuration.

	a) Open a terminal on your personal computer and run an nslookup, making sure to reference the assigned IP address of Traefik.
	It should return a Non-authoritative answer successfully.

	For example:

	```
	 nslookup homeassistant.homelab.domain.com
	 ```

	This should return your Traefik server. Either your IPV4 static WAN address, or the IPV6 address for the docker container.

## Further Information for CloudFlare

This requires a domain that is already registered and the DNS records are set up to be managed through CloudFlare.

Add an A type record or AAAA type record that has a unique name and points to the Traefik server. 
This could be directly to the servers IPV6 address or alternatively a static IPV4 address if you have one.
For IPV6 you may have to open the ports in your router firewall, or enable port forwarding for IPV4.

Once you have your A/AAAA record, you will need to create a wildcard CNAME record that points to the unique name.

For example:

| Type	| Name	        | Content							| Proxy Status
| ---		| ---           | ---									| ---
| A			| domain.com    | 12.34.56.78					| Proxied
| CNAME	| *							| domain.com					| Proxied
| AAAA	| homelab       | 2001:db8:cafe::1		| DNS only
| CNAME	| *.homelab     | homelab.domain.com	| DNS only

In this example the AAAA record is pointing directly to the Traefik docker container. It assumes that it has a global IPV6 address.

I am also using CloudFlare DNS challenge using an API token for issuing the SSL Certificates. 

1) Log into CloudFlare

2) Go to your profile

3) Click API Tokens on the left

4) Create a new token

5) Create a custom token

	a) Token name = Traefik
	 
	b) Permissions, Zone Zone Read, Zone DNS Edit
	
	c) Zone resources, Include Specific Zone homelab.com

6) Continue to summary

7) Copy the token to a safe place

8) Add the token to the environment variable in Portainer



## Further Information for Other Services

### Bind9

Refer to the boilerplate for Bind9 which includes an example zone.homelab.domain.com file.

### Authentik

Refer to the boilerplate for Authentik.