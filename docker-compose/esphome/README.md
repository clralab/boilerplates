# ESPHome Readme

Docker compose file for setting up ESPHome.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For ESPHome, I like to set this up on a macvlan. This gives a static IP on my home network.

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

This would only be an issue if you are looking to control the host in some way from ESPHome.
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

## Installation of ESPHome

1) Create the NFS folder on the NAS

2) Create a new stack in Portainer, name it "esphome" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	
	b) update the IP address to a static IP outside your DHCP range

3) Deploy the stack and check that it is running:

	a) Go to port 6052 on the IP address updated in the stack 
	
	b) It should give you a website showing ESPHome
 
## Setup of ESP01 Sensor

An example yaml config file is in the config folder. It is for an ESP01 that is connected to an OLED display and a Temperature and Humidity Sensor.

After flashing the ESP01 and plugging it in, it will connect to my home IOT WiFi Vlan.

There are many steps to build and flash an ESP01, and I apologise that this readme does not do the process justice, but things to watch out for include:

1) If using a USB UART connector, make sure to bridge GPIO0 to Ground

2) Make sure that a firewall or ACL rule has been created to allow ESPHome access to the IOT Vlan

3) I am currently getting an error that it's taking 0.12 seconds to read from the Temperature Sensor

4) Setting a static IP address outside the Vlan's DHCP range is advisable, remember to keep track, I have a spreadsheet

5) Once it is working, you will be able to add it to Home Assistant:

	a) In Home Assistant, go to Settings, and then click + Add Integration
	
	b) Search for ESPHome, select it and then type in the IP Address of the sensor
	
	c) You will be prompted for an encryption key, this comes from the YAML Config file

