#!/bin/bash

function printUsage() {
    cat <<EOF
Run the docker with the right options
Usage: sudo $(basename $0) [OPTIONS]
OPTIONS:
  -h: Help
  -d <name>: The name of the directory to mount at /home/root inside the docker
  -i <name>: The name of the docker image to run
EOF
    exit 1
}

MOUNT=`pwd`
IMAGE=modalai-1-0-0

while getopts 'hd:i:' opt
do
    case $opt in
	h)
	    printUsage
	    ;;
	d)
	    MOUNT="$OPTARG"
	    ;;
	i)
	    IMAGE="$OPTARG"
	    ;;
	*)
	    printUsage
	    ;;
    esac
done

# Make sure docker isn't running alrieady with specified container name
docker stop excelsior || echo "Making sure docker is not already running"
# Make sure specified docker container doesn't already exist because it will be created
docker rm excelsior || echo "Making sure docker does not already exist"

# Copy permissions over so root can access current directory
sudo chmod -R a+rwX .

# Run docker with the following options:
#       --rm            automatically remove container when exiting
#       -i              interactive
#       -t              allocate a pseudo TTY
#       --name          assign a name to the container
#       --privileged    give extended privileges to this container
#       -e              set environment variable within docker
#       -v              binf mount a volume/directory
#       -w              working directory string
docker run --rm \
           --name excelsior \
           --privileged \
           -it \
           -e LOCAL_USER_ID=0 -e LOCAL_USER_NAME=root -e LOCAL_GID=0 \
           -v ${MOUNT}:/home/root:rw \
           -w /home/root \
           ${IMAGE} /bin/bash

# Make sure anything created by the docker is accessible by user
sudo chmod -R a+rwX .
