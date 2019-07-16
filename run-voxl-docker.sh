#!/bin/bash

function printUsage() {
	cat <<EOF
Usage: $(basename $0) [ARGUMENTS]

By default this runs the ModalAI VOXL docker image. Any other installed
docker image can also be specified with the -i argument.

By default this mounts the current working directory as the home directory
inside the docker for easy compilation of whichever project you are currently
working in. The directory that gets mounted inside the docker can be manually
specified with the -d argument.

By default the user and group inside the docker image matches that of the user
that runs this script to avoid conflicting permissions. If you wish to run as
root inside the docker then use the -p option to run in privaledged mode.
This more closely mimics the on-target environment as the VOXL image runs as
root by default.

ARGUMENTS:
  -h:      : Print this help message
  -d <name>: The name of the directory to mount at /home/root inside the docker
  -i <name>: The name of the docker image to run
  -p       : Run the docker in privaledged mode (root user inside docker)
EOF
	exit 1
}

MOUNT=`pwd`			# mount current working directory by default
IMAGE=modalai-1-0-0	# run modalai apps proc build docker by default
PRIVALEDGED=false	# run in non-privaledged mode by default


# parse arguemnts (if any)
while getopts 'phd:i:' opt
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
	p)
		PRIVALEDGED=true
		;;
	*)
		printUsage
		;;
		esac
done

# unique instance name for the selected image
INSTANCE_NAME=${IMAGE}_1

# Make sure docker isn't running alrieady with specified container name
docker stop ${INSTANCE_NAME} || echo "Making sure docker is not already running"

# Make sure specified docker container doesn't already exist because it will be created
docker rm ${INSTANCE_NAME} || echo "Making sure docker does not already exist"


## Privaledged mode
if $PRIVALEDGED ; then
	# Run docker with the following options:
	# --rm			automatically remove container when exiting
	# -i			interactive
	# -t			allocate a pseudo TTY
	# --name		assign a name to the container
	# --privileged	give extended privileges to this container
	# -e			set environment variable within docker
	# -v			binf mount a volume/directory
	# -w			working directory string
	docker run \
		--rm -it \
		--name ${INSTANCE_NAME} \
		--privileged \
		-e LOCAL_USER_ID=0 \
		-e LOCAL_USER_NAME=root \
		-e LOCAL_GID=0 \
		-v `pwd`/:/home/root:rw \
		-w /home/root \
		$IMAGE /bin/bash

## non-privaledged mode (mortal user)
else
	echo "NORMAL MODE"
	# Run docker with the following options:
	# --rm			automatically remove container when exiting
	# -i			interactive
	# -t			allocate a pseudo TTY
	# --name		assign a name to the container so we can remove it later
	# -e			set environment variables within docker to match host user
	# -v			mount desired directory
	# -w			set working directory to home
	docker run \
		--rm -it \
		--name ${INSTANCE_NAME} \
		-e LOCAL_USER_ID=$(id -u) \
		-e LOCAL_USER_NAME=$(whoami) \
		-e LOCAL_GID=$(id -g) \
		-v ${MOUNT}:/home/$(whoami):rw \
		-w /home/$(whoami) \
		${IMAGE} /bin/bash
fi