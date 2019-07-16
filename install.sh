#!/bin/bash
#
# set up the modalai ARM docker image
# and install run-voxl-docker.sh to /usr/local/bin
#
# Modal AI Inc. 2019
# author: james@modalai.com

IMAGE=modalai-1-0-0
IMAGE_TAR=${IMAGE}.tar
RUN_SCRIPT=run-voxl-docker

# check prerequisites
command -v docker > /dev/null
RETVAL=$?
if [ $RETVAL -ne "0" ]; then
	echo "ERROR: docker executable not found."
	echo "follow instructions in README.md"
	exit 1
fi

set -e


# Copy docker from gcloud
if [ ! -f $IMAGE_TAR ]; then
	echo "Docker image tar not found"
	echo "please download from the ModalAI developer network:"
	echo "https://developer.modalai.com/asset/eula-download/3"
	exit 1
fi


echo "loading docker image"
sudo docker load -i $IMAGE_TAR
sudo docker images ${IMAGE} | grep ${IMAGE} || docker pull ${IMAGE}

echo "installing ${RUN_SCRIPT}.sh to /usr/local/bin/${RUN_SCRIPT}"
sudo install -m 0755 ${RUN_SCRIPT}.sh /usr/local/bin/${RUN_SCRIPT}

echo "DONE"