# Nvidia Exporter Readme

Nvidia drivers in Ubuntu can be tricky to get working. Below is most likely bound to change.

Resources will be provided at the bottom of the readme for further research or hints to resolve issue.
Much time has been spent on Stackoverflow and using either ChatGPT or Bing Chat to get things working.

## Prerequisites

Nvidia drivers must be installed. I recommend installing the cuda toolkit at the same time.

The best way to install the Nvidia drivers is using the "Additional Drivers" app within Ubuntu.
Log into the computer GUI and navigate to "Additional Drivers". Install the latest tested drivers.

> :warning: Note: the drivers may be greyed out. 
If so then I found the easiest way was to uninstall all Nvidia drivers and packages and start fresh.

Once the drivers are installed, then proceed to install the cuda toolkit:

> :warning: Note: the below will most likely change. 
Refer to Nvidia documentation for up to date information.

Remove Outdated Signing Key

```
apt-key del 7fa2af80
```

Install the new cuda-keyring package

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
&& dpkg -i cuda-keyring_1.0-1_all.deb
```

Enroll the new signing key manually

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004-keyring.gpg \
&& mv cuda-ubuntu2004-keyring.gpg /usr/share/keyrings/cuda-archive-keyring.gpg
```

Enable the network repository

```
echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" | sudo tee /etc/apt/sources.list.d/cuda-ubuntu2004-x86_64.list
```

Add pin file to prioritize CUDA repository

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin \
&& mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
```

Update the Apt repository cache

```
apt-get update
```

Once complete run nvidia-smi to check it is all working. A restart may be required.

```
nvidia-smi
```

## Adding a graphics card to Portainer

Change the directory to the GPU. Note the final folder may be different.

```
cd /proc/driver/nvidia/gpus/0000:02:00.0
```

To find the GPU UUID, run cat information.

```
cat information
```

In Portainer, go to Host -> then Setup -> then scroll down to GPU. 
Enter a GPU Name and paste in the UUID from cat information (include the GPU- prefix).
For example: GPU-26d53cff-7754-778a-6696-597d386af8e1

To test, run the following docker command:

```
docker run -it --gpus all nvidia/cuda:11.6.0-base-ubuntu20.04 nvidia-smi
```

## Install nvidia_exporter

1) Update the docker-compose file for network and DCGM image version.

> :warning: Note: to export data from DCGM host, DCGM of an equal or newer version to the container on the host system is required https://github.com/NVIDIA/DCGM

2) Copy the docker-compose service into the "prometheus" stack Web editor.

3) Edit the prometheus.yml configuration file to un-comment the nvidia_exporter job.

4) Re-deploy the stack and check that it is running:

	a) Go to port 9090 on the server
	b) Click Status -> Targets

There should be a target called "nvidia_exporter" and an endpoint nvidia_exporter:9400/metrics in the "Up" state.

## Resources

https://www.youtube.com/watch?v=c0Z_ItwzT5o
To install the CUDA toolkit seperately if required, this tutorial may help.

https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212771

https://developer.nvidia.com/dcgm