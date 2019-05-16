 ##
 # (C) Copyright 2018 Amplex, fm@amplex.dk
 ##
FROM ubuntu-stuffed
#FROM ubuntu:16.04

ARG WSPASSWD=
ENV WSPASSWD=${WSPASSWD}
    
MAINTAINER Flemming Madsen <amplexdenmark@gmail.com>

# From https://github.com/mlaccetti/docker-oracle-java8-ubuntu-16.04/blob/master/Dockerfile
ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8

RUN dpkg --add-architecture i386 && apt-get update
RUN apt-get --no-install-recommends install -y \
            zlib1g:i386  libncurses5:i386 libreadline6:i386 libwebsockets7:i386

RUN apt-get --no-install-recommends install -y bash-completion luajit busybox strace:i386 libnss3:i386
RUN apt-get --no-install-recommends install -y netcat iputils-ping file valgrind libc6-dbg:i386
RUN apt-get dist-upgrade -y && apt-get -y autoremove && apt-get -y autoclean

RUN apt-get update && apt-get upgrade -y \
 && apt-get --no-install-recommends install -y jq tmux psmisc lua-sql-postgres lua-sql-postgres:i386


ADD assets /assets
RUN bash -x /assets/setup.sh

ENTRYPOINT ["/sbin/startup.sh"]
CMD ["start", "-v"]

