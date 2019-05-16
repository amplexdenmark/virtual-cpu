#!/bin/bash

NAME="virtual-cpu"
IMAGE="virtual-cpu"
PORTS="--env SSH_PORT=32022"

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
    docker run --network="host" --detach --name $NAME --hostname localhost $PORTS --volume `pwd`/storage:/amplex -t $IMAGE start
}

shell() {
    common
    docker run --network="host" --name $NAME --hostname localhost $PORTS --volume `pwd`/storage:/amplex -it $IMAGE shell
}

bash() {
    common
    docker run --name $NAME --volume `pwd`/storage:/amplex -it --entrypoint=/bin/bash $IMAGE -i
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

[ $# -gt 0 ] || die "$0: 'start|stop|logs|tail'"
mkdir -p storage

"$@"
