## use 16.04 for now since it has gcc-4.9 in the standard repos
## update to something newer once VOXL is on a newer glibc
FROM ubuntu:16.04

# update base packages in noninteractive mode
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y upgrade

# basic dev tools
RUN apt-get -y install build-essential make cmake sudo curl unzip gcc wget git nano vim
# 32-bit cross compiler
RUN apt-get -y install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi
RUN apt-get -y install gcc-4.9-arm-linux-gnueabi g++-4.9-arm-linux-gnueabi
# 64-bit cross compiler
RUN apt-get -y install gcc-4.9-aarch64-linux-gnu g++-4.9-aarch64-linux-gnu
# these are misc things we need for building the kernel
RUN apt-get -y install gawk gperf help2man texinfo gperf bison flex texinfo make libncurses5-dev python-dev
# these are required to build opkg
RUN apt-get -y install libtool libtool-bin autoconf automake pkg-config libcurl4-openssl-dev openssl libssl-dev libgpgme11 libgpgme11-dev
# opkg needs at least v3.2 of libarchive, luckily xenial  backports has it
# can install this normally if this file is ever updated to
RUN apt-get -y install libarchive-dev/xenial-backports
# clean up the package cache to save space
RUN apt-get -y clean


# build and install opkg 0.4.3
RUN mkdir -p /opt/workspace/
RUN cd /opt/workspace/
RUN cd /opt/workspace/ && git clone https://git.yoctoproject.org/git/opkg
RUN cd /opt/workspace/opkg/ && git checkout tags/v0.4.3
RUN cd /opt/workspace/opkg/ && ./autogen.sh
RUN cd /opt/workspace/opkg/ && ./configure --sysconfdir=/etc
RUN cd /opt/workspace/opkg/ && make
RUN cd /opt/workspace/opkg/ && make install
RUN ldconfig

# cleanup the opkg source
RUN rm -rf /opt/workspace/opkg

# install our opkg config file
ADD opkg.conf /etc/opkg/opkg.conf

# add our toolchain files
ADD arm-gnueabi-4.9.toolchain.cmake /opt/cross_toolchain/
ADD aarch64-gnu-4.9.toolchain.cmake /opt/cross_toolchain/


