#!/bin/sh

### bw2mqtt.sh ###

WAN1=eth0.2

function stats()
{
getbytes="" && getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxaa=$(echo "$getbytes" | awk '{ print $3 }')
txaa=$(echo "$getbytes" | awk '{ print $8 }')

sleep 3

getbytes="" && getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxbb=$(echo "$getbytes" | awk '{ print $3 }')
txbb=$(echo "$getbytes" | awk '{ print $8 }')

echo RX $( expr $(expr $rxbb - $rxaa) / 1024 / 3 )

echo TX $( expr $(expr $txbb - $txaa) / 1024 / 3 )

}

stats $WAN1

### bw2mqtt.sh ###
##
#
