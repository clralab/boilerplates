# HomeAssistant Readme

Docker compose file for setting up Home Assistant and instructions for adding a Breville Smart Dehumidifier.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For HomeAssistant, I like to set this up on a macvlan. This gives a static IP on my home network.

There are three reasons for this:

1) Having a static IP means I can add a local DNS record on my home network

2) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier

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

This would only be an issue if you are looking to control the host in some way from HomeAssistant.
I have not found a need for this for now.

I also prefer to set up an NFS Share on my Synology NAS that will allow for backup of configuration files.
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

## Installation of HomeAssistant

1) Create the NFS folder on the NAS

2) Create a new stack in Portainer, name it "homeassistant" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

3) Deploy the stack and check that it is running:

	a) Go to port 8123 on the IP address updated in the stack 
	
	b) Create an account

### Allow CloudFlare Tunnel and Traefik Connection

Add the following to configuration.yaml updating the IP address to the container hosting the CloudFlare tunnel and Traefik:

```
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.0.2.xxx
    - 10.0.2.yyy
```

## Setting up LocalTuya Smart Devices

### Set up HACS

As HomeAssistant has been set up on Docker using Portainer, go into the terminal via Portainer and download HACS using:

```
wget -O - https://get.hacs.xyz | bash -
```

Once it has been download, log into HomeAssistant, click settings, then system, and then restart.

After restarting, go to settings, devices and services, click add integration, and search for HACS.

Restart HomeAssistant again and HACS should appear on the left menu.

### Set up Tuya 

In the future I may record my own video, however, standing on the sholders of giants Mark Watt Tech has a great
<a href="https://www.youtube.com/watch?v=f8-7Hvrmh3Y">Tutorial</a>
on Youtube

Even though we will be using LocalTuya to have a direct LAN connection to the dehumidifier, Tuya is required to get access to device and IoT IDs.

### Set up LocalTuya

Again, great tutorials alread exist, like this one This Smart House 
<a href="https://www.youtube.com/watch?v=VCd0kYWLvMQ">Tutorial</a>
on Youtube

LocalTuya will be available in HACS through the Explore and Download Repositories.

Through the process you will need to find each device's "Local Key". This can be found online in the Tuya IoT Platform API Explorer. 
First, under Cloud Development, copy the Device ID, you will need this for the next step.

To get the devices local key, go to:

Cloud -> API Explorer -> Device Management -> Query Device Details -> Enter Device ID -> Submit Request

There will be a field on the right under the details called "local_key".

### Add the Breville Smart Dry Connect Dehumidifier LAD208WHT2IAN1

The below entity table is courtesy of Yunseok_Oh from the
<a href="https://community.home-assistant.io/t/breville-smart-dry-connect-dehumidifier/401008/12">HomeAssistant Community</a>
:

| Entity	| Name	        | Platform	    | Value	                                        | Note
| ---       | ---           | ---           | ---                                           | ---
| 1	        | Power	        | switch	    | -	                                            | 
| 2	        | Dehumifier Mode | select      | 0;1;2;3 - Auto;Continuous;Laundry;Ventilation	| 
| 4	        | Humidity Target | number      | 30-80	                                        | Increment 5
| 6	        | Fan Speed	    | select	    | 1;3 - Low;High                                | 
| 7	        | Fault	        | binary_sensor	| -	                                            | 
| 11	    | Empty Tank	| sensor	    | -	                                            | 
| 12	    | TImer	        | select	    | 0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24 - Off;1 hour;2 hours;3 hours;4 hours;5 hours;6 hours;7 hours;8 hours;9 hours;10 hours;11 hours;12 hours;13 hours;14 hours;15 hours;16 hours;17 hours;18 hours;19 hours;20 hours;21 hours;22 hours;23 hours;24 hours	
| 101	    | Timer	        | binary_sensor	| -	                                            | 
| 102	    | Night Mode    | switch	    | -	                                            | 
| 103	    | Temperature   | sensor	    | Device Class: temperature, Unit: °	        | 
| 104	    | Humidity      | sensor	    | Device Class: humidity, Unit: %	            | 
| 105	    | Defrost       | binary_sensor	| -                                             | 

### Add the Breville Smart Air Purifier LAP408WHT

Entity table for the Air Purifier:

| Entity	| Name	        | Platform	    | Value	                                        | Note
| ---       | ---           | ---           | ---                                           | ---
| 1				| Power					| switch			| -	
| 2				| PM2.5 Level		| sensor			| -			| Unit μg/m³ Scaling Factor 0.1 
| 3				| Mode					| select			| 1;2 - Manual;Auto	
| 4				| Fan Speed			| select			| 1;2;3;4 - Low;Medium;High;Turbo	
| 8				| Night Mode		| switch			| -	
| 9				| Microbe Sheild	| switch			| -	
| 11			| Reset Filter	| switch			| -	
| 16			| Filter Left Days	| sensor			| -	
| 19			| Timer					| select			| cancle;2H;4H;12H - Off;2 hour;4 hours;12 hours	
| 20			| Left Time			| sensor			| -			| Unit Mins
| 21			| Warning				| binary_sensor			| 0;1 - OK;Replace Filter	
| 22			| Air Quality		| sensor			| 1;2;3;4 - Very Good;Good;Fair;Poor	

> :warning: Note that the timer has a spelling mistake. This is correct and must match the device value.

## Setting up wyoming-piper and faster-whisper-gpu

Thanks greatly to TechnoTim! Added this from his Self-Hosted AI Stack:

<a href="https://technotim.live/posts/ai-stack-tutorial/">Techno Tim's AI Stack</a>