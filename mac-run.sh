#!/bin/bash

NAME="virtual-cpu"
IMAGE="virtual-cpu"
PORTS="-p 32022:22"

die() {
  echo "$@"
  exit 1
}

common() {
    if docker ps -q --filter name=$NAME | grep -q ... ;then
       die "Already running"
    fi
    echo "Removing old containers .."
    docker ps -aq --filter name=$NAME | xargs docker rm -v
}

start() {
    common
    docker run --detach --name $NAME --hostname $NAME $PORTS --volume `pwd`/storage:/amplex -t $IMAGE
}

shell() {
    common
    docker run --name $NAME --hostname $NAME $PORTS --volume `pwd`/storage:/amplex -it $IMAGE shell
}

bash() {
    docker run --name $NAME --volume `pwd`/storage:/amplex -it --entrypoint=/bin/bash $IMAGE -i
}

stop() {
    docker ps -q --filter name=$NAME | xargs docker stop
}

logs() {
    docker ps -q --filter name=$NAME | xargs docker logs
}

tail() {
    docker ps -q --filter name=$NAME | xargs docker logs --follow
}

build() {
    common
    docker build -t ubuntu-stuffed git@github.com:amplexdenmark/ubuntu-stuffed.git
    docker build -t $IMAGE git@github.com:amplexdenmark/${IMAGE}.git
    docker image ls $IMAGE
}

build-local() {
    common
    if [ -z "$WSPASSWD" ] ;then
      echo "Importer password "
      read -s WSPASSWD
    else
      echo "Importer password from environment WSPASSWD"
    fi
    docker build -t ubuntu-stuffed git@github.com:amplexdenmark/ubuntu-stuffed.git
    docker build --build-arg WSPASSWD=$WSPASSWD -t $IMAGE .
    docker image ls $IMAGE
}

[ $# -gt 0 ] || die "$0: 'start|stop|logs|tail'"
mkdir -p storage

"$@"
