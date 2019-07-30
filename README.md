# voxl-docker

This project provides setup instructions for two docker images which provide build environments for the VOXL's ARM applications processor and Hexagon SDSP. It also provides the "voxl-docker" script for easily launching these docker images. These two docker images are prerequisites for building the majority of open-source projects on https://gitlab.com/voxl-public

#### voxl-emulator

We provide a Docker image in .tar format which contains the root file system that runs on VOXL itself. Through QEMU emulation and Docker, the ARM binaries in the VOXL rootFS can run on a desktop computer aiding development and speeding up compilation time. Anything that can be compiled onboard VOXL should be able to be compiled in voxl-emulator.

Note that this image is fairly clean and you will likely have to install build dependencies inside this docker image after launching it depending on which project you are compiling.

#### voxl-hexagon

The voxl-hexagon docker image is based on the x86_64 Ubuntu Bionic docker image but additionally contains the Qualcomm Hexagon SDK 3.1 and an ARM cross compiler. For legal reasons these components must be downloaded from their respective sources by the user before building the docker image. However, we provide instructions and an install script here in this project.



## Installation Instructions:

The following instructions are for installing docker and the two aforementioned Docker Images in an Ubuntu Desktop Environment. These instructions are tested on Ubuntu 18.04 Bionic but should work on other Ubuntu version supported by Docker.


#### Prerequisite: Install Docker CE

1) Official instructions are here:

https://docs.docker.com/install/linux/docker-ce/ubuntu/

However, they are summarized at time of writing as follows. we can't gurantee these commands are current whereas the above link should be current.

```bash
# install instructions from https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository -y \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

2) Add current user to docker group to allow usage of docker commands without root privileges. You will need to restart your OS after running this command for the group permissions to be applied.

```bash
sudo usermod -a -G docker $USER
sudo reboot
```



#### Install the voxl-emulator Docker Image
------------------------------

4) Download archived docker image from ModalAI Developer portal (login required):
    * [VOXL Emulator Docker Image (1.0.0)](https://developer.modalai.com/asset/eula-download/3)

5) Move archive into this directory alongside install-emulator-docker.sh and this README.md

6) Run configuration script to load docker image from archive and install the voxl-docker.sh script to /usr/local/bin so the docker image can be started from within other project directories.

```bash
./install-emulator-docker.sh
```

7) Test that the image was properly installed.

```bash
~/git/voxl-docker$ voxl-docker -l | grep "voxl"
voxl-emulator       latest              0e15518b8f95        11 months ago       1.26GB
```

#### (OPTIONAL) Install the voxl-hexagon Docker Image

If you wish to build programs for the Hexagon SDSP, you will need the Hexagon SDK from Qualcomm. To make this easier we provide the voxl-hexagon docker image which uses Hexagon SDK V3.1


8) Download and place the following files into cross_toolchain/downloads

Hexagon SDK 3.1 install file: qualcomm_hexagon_sdk_3_1_eval.bin

* https://developer.qualcomm.com/download/hexagon/hexagon-sdk-v3-1-linux.bin

Linaro ARM compiler binaries: gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf.tar.xz

* https://releases.linaro.org/archive/14.11/components/toolchain/binaries/arm-linux-gnueabihf

9) Run the install-hexagon-docker.sh script. This will also install voxl-docker.sh to usr/bin/ as did install-emulator-docker.sh in case the user wants the hexagon docker only.

```bash
./install-hexagon-docker.sh
```

10) Confirm the install worked

```bash
~/git/voxl-docker$ voxl-docker -l | grep "voxl"
voxl-hexagon        latest              6b7bb00b90d0        2 minutes ago       5.21GB
voxl-emulator       latest              0e15518b8f95        11 months ago       1.26GB
```



## Use of voxl-docker script

```bash
$ voxl-docker -h

Usage: run-voxl-docker.sh [ARGUMENTS]

By default this runs the ModalAI VOXL docker image. Any other installed docker image can also be specified with the -i argument.

By default this mounts the current working directory as the home directory inside the docker for easy compilation of whichever project you are currently working in. The directory that gets mounted inside the docker can be manually specified with the -d argument.

By default the user and group inside the docker image matches that of the user that runs this script to avoid conflicting permissions. If you wish to run as root inside the docker then use the -p option to run in privaledged mode. This more closely mimics the on-target environment as the VOXL image runs as root by default.

ARGUMENTS:
  -h:      : Print this help message
  -d <name>: The name of the directory to mount at /home/root inside the docker
  -i <name>: The name of the docker image to run
  -p       : Run the docker in privaledged mode (root user inside docker)
```

```bash
$ voxl-docker -l
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
voxl-hexagon        latest              637d89d3a530        19 minutes ago      5.28GB
voxl-emulator       latest              0e15518b8f95        1  months ago       1.26GB
```
