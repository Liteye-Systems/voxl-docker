# apps-proc-cross-compiler-docker

This project can be used to download and install the build environment for the VOXL applications processor. We provide a Docker image which contains the root file system that runs on VOXL itself. Through QEMU emulation and Docker, the ARM binaries in the VOXL rootFS can run on a desktop computer speeding up compilation time. Anything that can be compiled onboard VOXL should be able to be compiled in this docker image too.

Note that wihle this image does contain ROS, it is fairly clean and you will likely have to install other build dependencies inside this docker image after launching it depending on which project you are compiling.


## Prerequisite: Install dependencies

```bash
sudo apt-get install qemu-user-static android-tools-adb android-tools-fastboot
```

## Prerequisite: Install Docker CE

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

2) Add current user to docker group to allow usage of docker commands without root privaledges. You will need to restart your OS after running this command for the group permissions to be applied.

```bash
sudo usermod -a -G docker $USER
```



## Setup the ModalAI ARM Docker Image
------------------------------

4) Download archived docker image from ModalAI Developer portal (login required):
    * https://developer.modalai.com/
    * [VOXL Emulator Docker Image (1.0.0)](https://developer.modalai.com/asset/eula-download/3)

5) Move archive into this directory alongside install.sh and this README.md
    * cp [Download Dir]/modalai-1-0-0.tar ./docker-image/modalai-1-0-0.tar

6) Run configuration script to load docker image from archive and install the run-voxl-docker.sh script to /usr/local/bin so the docker image can be started from within other project directories.

```bash
./install.sh
```

## Run docker:
-----------
6) Now run it!

```bash
run-voxl-docker
```

7) Default behavior and optional arguments:

```bash
$ run-voxl-docker.sh -h

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