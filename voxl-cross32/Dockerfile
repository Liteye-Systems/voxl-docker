FROM ubuntu:16.04

RUN apt-get update

# Install required libraries
RUN apt-get -y install apt-utils wget gawk gperf help2man texinfo gcc gperf bison flex texinfo make libncurses5-dev python-dev unzip

RUN apt-get -y install --no-install-recommends libgtk2.0-dev
RUN apt-get clean --yes

RUN apt-get -y install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi
RUN apt-get -y install gcc-4.9-arm-linux-gnueabi g++-4.9-arm-linux-gnueabi

RUN apt install -y git build-essential cmake vim
RUN apt install -y sudo curl
