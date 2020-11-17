#!/bin/bash

function printUsage() {
	cat <<EOF
Usage: $(basename $0) [ARGUMENTS]

This is primarily used for running the voxl-emulator image for compiling ARM
apps-proc code for VOXL and the voxl-hexagon docker image for cross-compiling
hexagon SDSP programs. This can also launch any other installed docker image
with the -i argument.

By default this mounts the current working directory as the home directory
inside the docker for easy compilation of whichever project you are currently
working in. The directory that gets mounted inside the docker can be manually
specified with the -d argument.

The voxl-hexagon image starts with the username "user" with UID and GID 1000
which should match the first user on your desktop to avoid permissions issues.

The voxl-emulator image starts, by default, with the same username, UID, and GID
inside the docker as the user that launched it.

Since the voxl-emulator image is designed to emulate the userspace environment
that runs onboard the VOXL itself, you may wish to run as the root user inside
the voxl-emulator docker image to test certain behaviors as the root user.
This more closely mimics the on-target environment as the VOXL image runs as
root by default. Enter this mode with the -p option.

You can also specify the entrypoint for the docker image launch. By default this
is set to /bin/bash but can be user-configured with the -e option. This is most
likely used to pass the docker a command to execute before exiting automatically.
For example, to build the librc_math project in one command:

~/git/librc_math$ voxl-docker -i voxl-emulator -e "/bin/bash build.sh"


ARGUMENTS:
  -h:      : Print this help message
  -d <name>: The name of the directory to mount as ~/ inside the docker
  -i <name>: Docker image to run, usually voxl-emulator or voxl-hexagon
  -p       : for voxl-emulator image ONLY, runs as root user inside docker
  -l       : list installed docker images
  -e       : set the entrypoint for the docker image launch
EOF
	exit 1
}

EMULATOR="voxl-emulator"

MOUNT=`pwd`			# mount current working directory by default
IMAGE=""
PRIVALEDGED=false	# run in non-privaledged mode by default
USER_OPTS=""
MOUNT_OPTS=""
ENTRYPOINT="/bin/bash"


# parse arguemnts (if any)
while getopts 'phd:i:le:' opt
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
	e)
		ENTRYPOINT=$OPTARG
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

if [[ "${IMAGE}" == "" ]]; then
	printUsage
	exit 1
fi

echo "using image: $IMAGE"

## the emulator image behaves a little differently
if [[ ${IMAGE} == *"${EMULATOR}"* ]]; then
	if $PRIVALEDGED ; then
		USER_OPTS="-e LOCAL_USER_ID=0 -e LOCAL_USER_NAME=root -e LOCAL_GID=0"
		MOUNT_OPTS="-v ${MOUNT}/:/home/root:rw -w /home/root"
	else
		USER_OPTS="-e LOCAL_USER_ID=$(id -u) -e LOCAL_USER_NAME=$(whoami) -e LOCAL_GID=$(id -g)"
		MOUNT_OPTS="-v ${MOUNT}:/home/$(whoami):rw -w /home/$(whoami)"
	fi
# for all other images
else
	# tried to find a good way to run as current user inside docker but gave up
	# so just run as root
	USER_OPTS="-e LOCAL_USER_ID=0 -e LOCAL_USER_NAME=root -e LOCAL_GID=0"
	#USER_OPTS="-u $(id -u ${USER}):$(id -g ${USER})"
	#USER_OPTS="-e LOCAL_USER_ID=$(id -u) -e LOCAL_USER_NAME=$(whoami) -e LOCAL_GID=$(id -g) "
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

cmd=(
docker run \
	--rm -it \
	--net=host \
	--privileged \
	-w /home/$(whoami) \
	--volume="/dev/bus/usb:/dev/bus/usb" \
	$USER_OPTS\
	$MOUNT_OPTS \
	${IMAGE}\
	${ENTRYPOINT})

# print what's going to run
echo ${cmd[@]}
echo ""
# run it!
"${cmd[@]}"



