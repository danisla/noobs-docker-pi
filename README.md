# NOOBS Docker Ready Raspberry Pi Installer

A collection of [Pi-Kitchen](https://github.com/PiHw/Pi-Kitchen) recipes to configure a Raspberry Pi to run Docker containers automatically on boot.

The following operating systems can be configured:

- [HypriotOS](http://blog.hypriot.com/downloads/) (recommended)
- [Minibian](https://minibianpi.wordpress.com/category/release/) (wifi not working yet)

## How it works

Either download a prepared [NOOBS bundle](TODO) or use the script below to format and prepare a new SD card.

Run script to configure your pi with a given docker-compose.yml file, hostname, SSID, PSK etc.

```
./setup_sdcard.sh <path to docker-compose.yml>
```

Insert the SD card into the Pi and power on, the first run will install the OS and run the `_RUNONCE` scripts to finalize the configuration and import the cached docker images.

On each init process, the [`_RUNSTART`](./recipes/058-startup-docker-compose_INGREDIENTS/_RUNSTART/run_docker_compose.sh) script will start all services listed in the default `docker-compose.yml` located in the root directory of the SD card (recovery partition) and also run any `docker-compose.yml` files found in the `/_USER/docker_runstart` directory, also found on the FAT32 recovery partition which you can easily modify from your computer via SD card adapter.

## Building a new image.

Make sure you have the following installed before building a new image:

 - [Docker](https://www.docker.com/docker-toolbox)
 - dos2unix (install via [Home Brew](http://brew.sh/)) `brew install dos2unix`
 - [Vagrant](https://www.vagrantup.com/) (for creating fs tarballs on OSX)
 - [HypriotOS SD Card image](http://blog.hypriot.com/downloads/).

Run the [`setup_sdcard.sh`](./setup_sdcard.sh) script that will walk you through formatting and configuring a blank SD card.

### Using Vagrant to create the filesystem tarballs

NOTE: Normally vagrant is called from the `setup_sdcard.sh` script automatically, these steps are for debugging purposes.

If you want to rebuild the NOOBs card with a new version of of the base OS, use Vagrant to recreate the `boot.tar.xz` and `root.tar.xz`.

First install [Vagrant](https://www.vagrantup.com/downloads.html), then run this:

```
export OS_NAME="Minibian"
export RPI_IMG=${HOME}/Downloads/2015-11-12-jessie-minibian.img
vagrant up --provision
```

This will convert the .img file to a .vdi, start a VM, mount the image and tar xz the boot and root partitions to your host machines `./os/${OS_NAME}/` dir. These files can then be copied to the NOOBS SD card under `os/${OS_NAME}/`

Afterwards you can delete the vagrant VM.

```
vagrant destroy
```
