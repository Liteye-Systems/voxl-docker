##
## Dockerfile for building with Hexagon SDK 3.1 toolchain
##
## Author: James Strawson, Alex Kozarev
## Copyright (c) 2019 ModalAI, Inc.
##

FROM ubuntu:bionic
ENV DEBIAN_FRONTEND noninteractive

# Add repo for the right gcc
RUN apt-get update \
   && apt-get -y --quiet --no-install-recommends install software-properties-common

RUN add-apt-repository ppa:ubuntu-toolchain-r/test

# Now install the packages
RUN apt-get update \
   && apt-get -y --quiet --no-install-recommends install \
      gawk \
      wget \
      git-core \
      diffstat \
      unzip \
      texinfo \
      build-essential \
      chrpath \
      bzip2 \
      zip \
      cpio \
      bc \
      make \
      autoconf \
      automake \
      libtool \
      wget \
      curl \
      sudo \
      libxml-simple-perl \
      doxygen \
      qemu-user-static \
      android-tools-fsutils \
      debootstrap \
      schroot \
      vim \
      less \
      iputils-ping \
      python \
      python-pip \
      python-setuptools \
      gcc-7-arm-linux-gnueabi \
      g++-7-arm-linux-gnueabi \
      cmake \
      rsync \
      android-tools-adb \
      android-tools-fastboot \
      libusb-1.0-0-dev \
      usbutils \
   && apt-get clean autoclean \
   && pip install --upgrade pip \
   && curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
   && chmod a+x /usr/bin/repo \
   && echo "dash dash/sh boolean false" | debconf-set-selections \
   && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Add a non-root user with the following details:
# username: user
# password: user
# Home dir: /home/user
# Groups   : sudo, user
RUN /usr/sbin/useradd -m -s /bin/bash -G sudo user \
   && echo user:user | /usr/sbin/chpasswd

# Add the files to configure the build environment
ADD cross_toolchain /opt/cross_toolchain

# Install cross-toolchain
RUN cd /opt/cross_toolchain && ./installsdk.sh --APQ8096 --arm-gcc /opt/

# Add DSP Abstraction Layer (DSPAL) files to environment
ADD dspal /opt/dspal
ENV DSPAL_DIR=/opt/dspal

# Add cmake_hexagon macros and toolchain files
ADD cmake_hexagon /opt/cmake_hexagon
ENV CMAKE_HEXAGON_DIR=/opt/cmake_hexagon

# Create symbolic link to cross compiler for user
RUN ln -s /opt/Qualcomm/ARM_Tools/gcc-4.9-2014.11 /opt/Qualcomm/Hexagon_SDK/3.1/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabi_linux

# Put device rule to configure USB for Hexagon SDK debug tool mini-dm
RUN mkdir -p /etc/udev/rules.d
ADD files/70-android.rules /etc/udev/rules.d/70-android.rules

# erase old install files to shrink docker size
RUN rm -rf /opt/cross_toolchain/downloads/*

# set environment variables
ENV HEXAGON_SDK_ROOT=/opt/Qualcomm/Hexagon_SDK/3.1
ENV HEXAGON_TOOLS_ROOT=/opt/Qualcomm/Hexagon_SDK/3.1/tools/HEXAGON_Tools/8.0.08/Tools
ENV ARM_CROSS_GCC_ROOT=/opt/Qualcomm/ARM_Tools/gcc-4.9-2014.11
ENV HEXAGON_ARM_SYSROOT=/opt/Qualcomm/ARM_Tools/gcc-4.9-2014.11/libc/
ENV MINI_DM=${HEXAGON_SDK_ROOT}/tools/debug/mini-dm/Linux_Debug/mini-dm
