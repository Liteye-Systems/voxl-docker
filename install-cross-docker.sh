#!/bin/bash

set -e

VERSION="V2.3"
RUN_SCRIPT=voxl-docker


CLEAN=""
if [ "$1" == "clean" ]; then
	CLEAN="--no-cache"
	echo "starting clean build"
fi

# Check required files exit
if [ ! -f voxl-cross/qualcomm-proprietary_0.0.1.ipk ] ||
   [ ! -f voxl-cross/apq8096-proprietary_0.0.3.ipk ]  ||
   [ ! -f voxl-cross/qrb5165-proprietary_0.0.2_arm64.deb ]  ||
   [ ! -f voxl-cross/royale-331-spectre-4-7_1.1.0_arm64.deb ]; then

	echo ""
	echo "Missing one or more of the following required files"
	echo "qualcomm-proprietary_0.0.1.ipk"
	echo "apq8096-proprietary_0.0.3.ipk"
	echo "qrb5165-proprietary_0.0.2_arm64.deb"
	echo "royale-331-spectre-4-7_1.1.0_arm64.deb"
	echo ""
	echo "Please following the instruction in the README to download"
	echo "these files from downloads.modalai.com and place in voxl-cross/"
	exit 1
fi

# build the provides meta package
cd voxl-cross
DIR="cross_provides_meta_pkg"
PKG_VERSION=$(cat $DIR/DEBIAN/control | grep "Version" | cut -d' ' -f 2)
PKG_NAME=$(cat $DIR/DEBIAN/control | grep "Package" | cut -d' ' -f 2)
DEB_NAME=${PKG_NAME}_${PKG_VERSION}_arm64.deb
dpkg-deb --build ${DIR} ${DEB_NAME}
cd ../


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
