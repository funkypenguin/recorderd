#!/bin/sh

addr=`hostname`
port=8083

# If we received credentials for the ping test from docker, then add them to the curl command
if [ -n ${PING_PASSWORD} ]
then
  AUTHSTRING="-u ${PING_USER}:${PING_PASSWORD}"
fi

epoch=$(date +%s)

location=$(cat <<EOJSON
{
  "_type": "location",
  "tid": "pp",
  "lat": 51.47879,
  "lon": -0.010677,
  "tst": $epoch
}
EOJSON
)

# POST location to ping/ping, ignoring output
curl -sSL $AUTHSTRING --data "${location}" "http://${addr}:${port}/pub?u=ping&d=ping" > /dev/null

# obtain tst of ping/ping's last location
ret_epoch=$(curl -sSL $AUTHSTRING http://${addr}:${port}/api/0/last --data "user=ping&device=ping" |
	    env python -c 'import sys, json; print json.load(sys.stdin)[0]["tst"];')

if [ $epoch -ne $ret_epoch ]; then
	echo PANIC $epoch $ret_epoch
	exit 1
else
	echo OK
	exit 0
fi
