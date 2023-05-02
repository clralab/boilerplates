# Grafana Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For Grafana, I like to set this up on a macvlan. This gives a static IP on my home network.

There are two reasons for this:

1) The default port for Grafana is 3000 and this can conflict with other services like Gitea

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

This means that Grafana needs to also be added to any bridge networks serving data to be reported.
Such as the prometheus bridge network.

## Installation of Grafana

1) Create the NFS folder on the NAS

2) Create a new stack in Portainer, name it "grafana" and copy the docker-compose code into Web editor.

	a) Update the volume to match the folder created on the NFS
	b) update the IP address to a static IP outside your DHCP range

3) Deploy the stack and check that it is running:

	a) Go to port 3000 on the IP address updated in the stack 
	b) Enter the default username and password, admin and admin

4) Optional - set up prometheus connection

	a) in the stack un-comment and update the prometheus lines based on your setup
	b) redeploy the stack which will also restart the Grafana container
	c) log into Grafana using port 3000 on the static IP
	d) go to Settings -> Data sources -> Add data source -> Prometheus
	e) in the URL, enter http://prometheus:9090 (as the IP address may change in the Docker DHCP)

## Dashboards

Under the config folder there are a few example reports. 
These have either been modified from existing templates or written from scratch.

- Monitoring - requires node_exporter and nvidia_exporter containers
- Cadvisor - requires cadvisor container
- Synology - requires snmp_exporter container