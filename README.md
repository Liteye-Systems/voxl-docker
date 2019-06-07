# apps-proc-cross-compiler-docker

This project can be used to create the cross-compiler build environment for the VOXL applications processor

## Setting up docker environment:
------------------------------
1. Install qemu:
        * sudo apt-get install qemu-user-static
2. Install Docker CE as shown:
        * https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/
3. [Optional] Add current user to docker group to allow usage of docker commands without `sudo`:
        * sudo usermod -a -G docker $USER
4. [Optional] Make docker available to all non-root users:
        * sudo chmod 777 /var/run/docker.sock
5. Install adb
        * sudo apt-get install android-tools-adb android-tools-fastboot
6. Download archived docker ARM image from ModalAI Developer portal (login required):
        * https://developer.modalai.com/
7. Copy tar archive into the 'docker-image' directory
        * cp [Download Dir]/modalai-1-0-0.tar ./docker-image/modalai-1-0-0.tar
8. Run configuration script to load docker image from archive:
        * ./configure_docker.sh

## Run docker:
-----------
1. Run script to create docker container in current directory:
        * ./run_docker