#!/bin/bash
echo "STARTUP: $@"

die() {
    echo "$@"
    exit 1
}

common() {
    if [[ ! -d /amplex/home ]] ;then
        echo "Amplex init. Please configure"
        cp -rp /assets/home /amplex
        chown -R amplex:amplex /amplex/home
    fi
    mkdir -p /amplex/virtcpu/install
    [ -f /amplex/crontab.amplex ] || cp /assets/crontab.amplex /amplex
    [ -f /amplex/crontab.root ] || cp /assets/crontab.root /amplex
    crontab /amplex/crontab.root
    crontab -u amplex /amplex/crontab.amplex


    /etc/init.d/cron start

    : ${SSH_PORT:=22}
    /etc/init.d/ssh start "-p $SSH_PORT"

    sudo --login --user=amplex bash -c "mkdir -p /amplex/home/.config"

}

start() {
    common
    shift
    (sudo --login --user=amplex cpu-start.sh "$@" &)
    while true ;do wait ; sleep 0.25 ;done # Keep it running while reaping any burpy daemons
}

shell() {
    common
    sudo --login --user=amplex bash "$@"
}

run() {
    sudo --login --user=amplex "$@"
}

findmnt /amplex >/dev/null || die "FATAL: The /amplex folder must be mounted to an external location."

"$@"
