#!/bin/bash

IMAGE=modalai-1-0-0
IMAGE_TAR=${IMAGE}.tar

# load image from TAR archive file instead of STDIN
docker load -i ./docker-image/${IMAGE_TAR}
# check current images for this image by name. if not found, pull image from registry.
docker images ${IMAGE} | grep ${IMAGE} || docker pull ${IMAGE}
