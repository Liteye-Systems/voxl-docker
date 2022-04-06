# See https://github.com/tianon/docker-brew-ubuntu-core/blob/f6c798bd7248f69db272e17677153fc119f41301/bionic/Dockerfile

# 'scratch' is an empty docker image
FROM scratch

# add the rootfs contents from the system image build output
ADD data/rootfs /

# required for ARM emulation
COPY ./bin/qemu-arm-static /usr/bin/qemu-arm-static

# fix permissions on /tmp to let apt update run
RUN chmod 1777 /tmp

# install helpers
RUN apt-get -y update
RUN apt-get -y install git cmake sudo

# remove opencv
RUN apt-get -y remove libopencv-dev
RUN apt-get -y autoremove

# install common dependencies
RUN apt-get -y install libusb-1.0-0 libusb-1.0-0-dev

# 32-bit cross compiler for mv-based things
RUN apt-get install -y g++-7-multilib-arm-linux-gnueabi

# Install GStreamer RTSP server development files since they aren't included
# with the rootfs
RUN apt-get -y install libgstrtspserver-1.0-dev

# Install a file that indicates what docker image this is
# so that it can be known inside the container
RUN mkdir -p /etc/modalai
RUN touch /etc/modalai/qrb5165-emulator.id

# TODO: Change the prompt
# RUN echo PS1="\"\[\e[1m\]\[\e[33m\]qrb5165-emulator\[\e[0m\]:\[\e[1m\]\[\e[34m\]\w\[\e[0m\]$\"" > /root/.bashrc
# RUN echo 'export PS1="\[\e[1m\]\[\e[33m\]qrb5165-emulator\[\e[0m\]:\[\e[1m\]\[\e[34m\]\w\[\e[0m\]$' >> /root/.bash_profile

# start in /home/root
WORKDIR /home/root

CMD ["/bin/bash"]
