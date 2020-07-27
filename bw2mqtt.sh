#!/bin/sh

### bw2mqtt.sh ###

WAN1=eth0.2
TOPIC=wrt2mqtt/bw

function stats()
{
getbytes="" && getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxaa=$(echo "$getbytes" | awk '{ print $3 }')
txaa=$(echo "$getbytes" | awk '{ print $8 }')

sleep 3

getbytes="" && getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxbb=$(echo "$getbytes" | awk '{ print $3 }')
txbb=$(echo "$getbytes" | awk '{ print $8 }')

result_rx="" && result_rx=$( expr $(expr $rxbb - $rxaa) / 1024 / 3 )
result_tx="" && result_tx=$( expr $(expr $txbb - $txaa) / 1024 / 3 )

echo RX $result_rx
echo TX $result_tx

mosquitto_pub -t $TOPIC/rx -m $result_rx
mosquitto_pub -t $TOPIC/tx -m $result_tx

}

stats $WAN1

### bw2mqtt.sh ###
##
#
