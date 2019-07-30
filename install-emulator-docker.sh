#!/bin/bash
################################################################################
# Copyright 2019 ModalAI Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# 4. The Software is licensed to be used solely in conjunction with devices
#    provided by ModalAI Inc.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
################################################################################

IMAGE=modalai-1-0-0
IMAGE_TAR=${IMAGE}.tar
RUN_SCRIPT=voxl-docker

# check prerequisites
command -v docker > /dev/null
RETVAL=$?
if [ $RETVAL -ne "0" ]; then
	echo "ERROR: docker executable not found."
	echo "follow instructions in README.md"
	exit 1
fi

set -e

# make sure user has downlaoded the image file
if [ ! -f $IMAGE_TAR ]; then
	echo "Docker image tar not found"
	echo "please download from the ModalAI developer network"
	echo "and place the file in the current directory"
	echo "https://developer.modalai.com/asset/eula-download/3"
	exit 1
fi

echo "installing misc. dependencies"
sudo apt install qemu-user-static android-tools-adb android-tools-fastboot

echo "loading docker image"
sudo docker load -i $IMAGE_TAR
sudo docker tag $IMAGE:latest voxl-emulator:latest

sudo docker images ${IMAGE} | grep ${IMAGE} || docker pull ${IMAGE}

echo "installing ${RUN_SCRIPT}.sh to /usr/local/bin/${RUN_SCRIPT}"
sudo install -m 0755 files/${RUN_SCRIPT}.sh /usr/local/bin/${RUN_SCRIPT}

echo "DONE"