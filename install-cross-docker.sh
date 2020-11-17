#!/bin/bash

RUN_SCRIPT=voxl-docker


# Build Docker image
cd voxl-cross
docker build -t voxl-cross -f voxl-cross.Dockerfile .
cd ../

# install the voxl-docker helper script
echo "installing ${RUN_SCRIPT}.sh to /usr/local/bin/${RUN_SCRIPT}"
sudo install -m 0755 files/${RUN_SCRIPT}.sh /usr/local/bin/${RUN_SCRIPT}

echo "DONE"
