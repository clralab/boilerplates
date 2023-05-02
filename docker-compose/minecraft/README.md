# Minecraft Readme

Use the docker compose file to create the volumes and container.

## Prerequisites

My personal preference is to isolate application stacks on their own networks.
For Minecraft, I like to set this up on a macvlan. This gives a static IP on my home network.

There are two reasons for this:

1) Having a static IP means I can add a local DNS record on my home network
(great for sharing with family members on the local network).

2) Setting up a zero trust tunnel with a provider like Cloudflare is a bit easier 
(note Cloudflare tunnel doesn't work for Minecraft port).

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

I also prefer to keep all configuration files and data stored on my NAS.
This way I can easily access and update if required without having to terminal into the container.
It also allows for easier backup, which comes in handy for Minecraft to revert to before mistakes.

Make sure to update the IP address and device in the vol_nfs_minecraft volume to match your configuration. 
Alternatively this can be changed to a local volume by removing the "driver_opts" section.
If you do this, it might be a good idea to change the volume name as well to remove the NFS reference.

> :warning: Note: you may have to set up the Squash as "Map root to Admin".
On a Synology NAS this is done at the Shared Folder level in Control Panel.

## Installation of Minecraft

1) Create the NFS folder on the NAS and set up the Squash as "Map root to Admin".

2) Copy the docker-compose volume and service into a new stack in the Web editor in Portainer.

3) Deploy the stack and check that it is running under containers. 
This will download the latest version of Minecraft Server and set up the files.

4) Update the server files if required such as Server.Properties or Allowlist.JSON.

5) Restart the container after changing any properties to take effect.

