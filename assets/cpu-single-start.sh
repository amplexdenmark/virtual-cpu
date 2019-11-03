#!/bin/bash
###
# @file cpu-start.sh
# ABSTRACT HERE << 
#
# $Id$
#
# (C) Copyright 2018 Amplex, fm@amplex.dk
#
WSPASSWD=`cat /opt/amplex/.wspasswd`
customerid=$1
echo "CPU start $customerid"
localhost=localhost
export PATH=$PATH:/opt/virtcpu/install/root/usr/bin
grep -s -q linuxkit /proc/version && localhost=host.docker.internal
pid=`pgrep -f $((4002000000 + $customerid))`
echo "PID: $pid" 
if [ ! -z "$pid" ] ;then
    echo "Killing existing virtual-cpu for customer: $customerid"
    kill $pid
fi

# Try curl login with "nodes" ws
curl_mksession() {
  CODE=$(curl -s --cookie /tmp/ampimp-cookie-jar --cookie-jar /tmp/ampimp-cookie-jar -w '%{http_code}\n' \
         -H 'Authorization: Basic aW1wb3J0ZXI6SnVtcGluZ0Zpc2hTdGlja0F0MTg=' http://$localhost:8008/aasws/nodes -o /dev/null)
  [[ $CODE == 200 ]] && echo --cookie /tmp/ampimp-cookie-jar || echo "-uimporter:$WSPASSWD"
}

lorawan_customers() {
    LOGIN=$(curl_mksession)
  curl -s $LOGIN http://$localhost:8008/sso/r/customer > /tmp/customers.json
  cat /tmp/customers.json | jq -j '.[] | select(.systems) | select(.systems| .[] | .=="amplex.gridlight-lorawan") | "\(.id)\t\(.name)\t\(.systemsConfiguration)\n"'
}

lorawan_customers | while IFS=$'\t' read id name sysconf ;do
  srvr=$(amp-param lorawan-driver "server-${name// /-}")
  if [ -z "$srvr" ] ;then
    srvr=$(amp-param lorawan-driver server)
    : ${srvr:=lorawan-server}
  fi
  if [ "null" == "$sysconf" ] ;then
      continue
  fi
  if [ "$customerid" != "$id" ] ;then
      echo "disregarding $id"
      continue;
  fi    
  spec=`echo $sysconf | jq '.["amplex.gridlight-lorawan"]' `
#  spec=$(amp-param lorawan-driver "spec-${name// /-}")
#  if [ -z "$spec" ] ;then
#    spec='{
#       "type":"ghp-lorawan-server",
#       "name":"AmpLoRaWAN-{NAME}",
#       "rest":"http://{SERVER}/",
#       "sock":"ws://{SERVER}/",
#       "customer":{CUST},
#    }'
#  fi
  spec=${spec//'{CUST}'/$id}
  spec=${spec//'{NAME}'/$name}
  spec=${spec//'{SERVER}'/$srvr}
  spec=${spec//$'\n'/}
  spec=${spec//'"'/'\"'}
  echo "$spec" > /tmp/lorawan_driver_driver_spec_$id
  serial=$((4002000000 + id))
  paramdir=/opt/virtcpu/ramdisk/$serial/tmp/param/lorawan-driver.cdir
  mkdir -p $paramdir
  echo "$id" > $paramdir/customer
  echo "$spec" > $paramdir/driver-spec
  env LOG_USE_STDOUT=1 LOG_STDOUT_PREFIX="$(printf "%04d " $id)" \
      virtcpu virtcpu-run $serial $localhost &
done
# vim: set sw=2 sts=2 et:
