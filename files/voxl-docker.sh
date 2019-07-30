#!/bin/bash

function printUsage() {
	cat <<EOF
Usage: $(basename $0) [ARGUMENTS]

By default this runs the voxl-emulator image for compiling ARM apps-proc code
for VOXL. It can also run the voxl-hexagon docker image for cross-compiling
hexagon SDSP programs. Technically this can also launch any other installed
docker image with the -i argument but is only tested with the voxl-emulator
and voxl-hexagon images.

By default this mounts the current working directory as the home directory
inside the docker for easy compilation of whichever project you are currently
working in. The directory that gets mounted inside the docker can be manually
specified with the -d argument.

For both the voxl-emulator and voxl-hexagon images, the default the user and
group ID inside the docker image matches that of the user that runs this script
to avoid conflicting permissions.

Since the voxl-emulator image is designed to emulate the userspace environment
that runs onboard the VOXL itself, you may wish to run as the root user inside
the voxl-emulator docker image to test certain behaviors as the root user.
This more closely mimics the on-target environment as the VOXL image runs as
root by default. Enter this mode with the -p option.

ARGUMENTS:
  -h:      : Print this help message
  -d <name>: The name of the directory to mount as ~/ inside the docker
  -i <name>: Docker image to run, usually voxl-emulator or voxl-hexagon
  -p       : for voxl-emulator image ONLY, runs as root user inside docker
  -l       : list installed docker images
EOF
	exit 1
}

EMULATOR=voxl-emulator

MOUNT=`pwd`			# mount current working directory by default
IMAGE=$EMULATOR		# run modalai apps proc build docker by default
PRIVALEDGED=false	# run in non-privaledged mode by default
USER_OPTS=""
MOUNT_OPTS=""


# parse arguemnts (if any)
while getopts 'phd:i:l' opt
do
	case $opt in
	h)
		printUsage
		;;
	d)
		MOUNT=$(realpath $OPTARG)
		echo "Using ${MOUNT} as home directory inside docker"
		;;
	i)
		IMAGE="$OPTARG"
		;;
	p)
		PRIVALEDGED=true
		;;
	l)
		docker images
		exit 0
		;;
	*)
		printUsage
		;;
		esac
done

# make unique instance name for the selected image by appending '_1'
INSTANCE_NAME=${IMAGE}-1

# make sure the container isn't already running
docker container ls | grep -q ${INSTANCE_NAME}
if [ $? == 0 ]; then
	echo "stopping existing instance of $INSTANCE_NAME"
	docker stop ${INSTANCE_NAME}
fi

## the emulator image behaves a little differently
if [ $IMAGE == $EMULATOR ]; then
	if $PRIVALEDGED ; then
		USER_OPTS="-e LOCAL_USER_ID=0 -e LOCAL_USER_NAME=root -e LOCAL_GID=0"
		MOUNT_OPTS="-v ${MOUNT}/:/home/root:rw -w /home/root"
	else
		USER_OPTS="-e LOCAL_USER_ID=$(id -u) -e LOCAL_USER_NAME=$(whoami) -e LOCAL_GID=$(id -g)"
		MOUNT_OPTS="-v ${MOUNT}:/home/$(whoami):rw -w /home/$(whoami)"
	fi
# for all other images
else
	USER_OPTS="-u $(id -u ${USER}):$(id -g ${USER})"
	MOUNT_OPTS="-v ${MOUNT}/:/home/user:rw -w /home/user"
fi


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
	-w /home/$(whoami) \
	--volume="/dev/bus/usb:/dev/bus/usb" \
	$USER_OPTS $MOUNT_OPTS \
	${IMAGE} /bin/bash
