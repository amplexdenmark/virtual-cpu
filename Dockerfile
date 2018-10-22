 ##
 # (C) Copyright 2018 Amplex, fm@amplex.dk
 ##
FROM ubuntu-stuffed
#FROM ubuntu:16.04

MAINTAINER Flemming Madsen <amplexdenmark@gmail.com>

# From https://github.com/mlaccetti/docker-oracle-java8-ubuntu-16.04/blob/master/Dockerfile
ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8

RUN dpkg --add-architecture i386 && apt-get update
RUN apt-get --no-install-recommends install -y \
            zlib1g:i386  libncurses5:i386 libreadline5:i386 libwebsockets7:i386

RUN apt-get --no-install-recommends install -y bash-completion

RUN apt-get dist-upgrade -y && apt-get -y autoremove && apt-get -y autoclean


ADD assets /assets
RUN bash -x /assets/setup.sh

ENTRYPOINT ["/sbin/startup.sh"]
CMD ["start", "-v"]

