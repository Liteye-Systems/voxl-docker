#!/bin/bash

set -e

VERSION="V2.0"
RUN_SCRIPT=voxl-docker


CLEAN=""
if [ "$1" == "clean" ]; then
	CLEAN="--no-cache"
	echo "starting clean build"
fi

# Add bash utilities
cd bash_utilities
./make_package.sh
cd ..
cp ./bash_utilities/bash_utilities.tar voxl-cross/

# Build Docker image
cd voxl-cross
docker build $CLEAN -t voxl-cross:${VERSION} -f voxl-cross.Dockerfile .
docker tag voxl-cross:${VERSION} voxl-cross:latest
cd ../

# install the voxl-docker helper script
echo "installing ${RUN_SCRIPT}.sh to /usr/local/bin/${RUN_SCRIPT}"
sudo install -m 0755 files/${RUN_SCRIPT}.sh /usr/local/bin/${RUN_SCRIPT}

echo "DONE"
