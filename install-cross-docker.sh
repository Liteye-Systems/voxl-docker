#!/bin/bash

RUN_SCRIPT=voxl-docker


# Build Docker image
cd voxl-cross
docker build --no-cache -t voxl-cross:V1.1 -f voxl-cross.Dockerfile .
docker tag voxl-cross:V1.1 voxl-cross:latest
cd ../

# install the voxl-docker helper script
echo "installing ${RUN_SCRIPT}.sh to /usr/local/bin/${RUN_SCRIPT}"
sudo install -m 0755 files/${RUN_SCRIPT}.sh /usr/local/bin/${RUN_SCRIPT}

echo "DONE"
