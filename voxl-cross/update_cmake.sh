#!/bin/bash

version=3.22
build=1

## don't modify from here
echo "Downloading cmake source V$version"
cd /tmp
wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz
tar -xzvf cmake-$version.$build.tar.gz
cd cmake-$version.$build/
echo "building"
./bootstrap
make -j$(nproc)
sudo make install

echo "done building cmake $version Test install using cmake --version"
cmake --version
