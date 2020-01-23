#!/bin/bash

NAME="virtual-cpu"
IMAGE="virtual-cpu"
PORTS="--env SSH_PORT=32022"
LOGS="--log-opt max-size=50m --log-opt max-file=2"
NAMES="--name $NAME --hostname localhost"
OPTS="--network=host"
MOUNT="--volume `pwd`/storage:/amplex"

die() {
  echo "$@"
  exit 1
}

common() {
    if docker ps -q --filter name=$NAME | grep -q ... ;then
       die "Already running"
    fi
    echo "Removing old containers .."
    docker ps -aq --filter name=$NAME | xargs -r docker rm -v
}

start() {
    common
    echo "Starting $NAME .."
    docker run $OPTS $NAMES $LOGS $PORTS $MOUNT -t --detach $IMAGE start
}

shell() {
    common
    docker run $OPTS $NAMES $LOGS $PORTS $MOUNT -it $IMAGE shell
}

bash() {
    common
    docker run $OPTS $NAMES $LOGS $PORTS $MOUNT -it --entrypoint=/bin/bash $IMAGE -i
}

connect() {
    docker exec -it `docker container ls | grep virtual-cpu | cut -c 1-12` "bash"
}

stop() {
    docker ps -q --filter name=$NAME | xargs -r docker stop
}

logs() {
    docker ps -q --filter name=$NAME | xargs -r docker logs
}

tail() {
    docker ps -q --filter name=$NAME | xargs -r docker logs --follow
}

build() {
    docker build -t ubuntu-stuffed git@github.com:amplexdenmark/ubuntu-stuffed.git
    docker build -t $IMAGE git@github.com:amplexdenmark/${IMAGE}.git
}

clean-build() {
    docker build -t ubuntu-stuffed git@github.com:amplexdenmark/ubuntu-stuffed.git
    docker build --no-cache -t $IMAGE git@github.com:amplexdenmark/${IMAGE}.git
}


[ $# -gt 0 ] || die "$0: 'start|stop|logs|tail'"
mkdir -p storage

"$@"
