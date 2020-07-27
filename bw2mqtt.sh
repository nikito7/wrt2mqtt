#!/bin/sh

### bw2mqtt.sh ###

NAME="Router 1"
ID=router_10_1_0_1
WAN1=eth0.2
TOPIC=wrt2mqtt

###

mosquitto_pub -t homeassistant/sensor/${ID}/bw/rx/config \
-m "test"

mosquitto_pub -t homeassistant/sensor/${ID}/bw/tx/config \
-m "test"

###

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

mosquitto_pub -t ${TOPIC}/${ID}/status -m online
mosquitto_pub -t ${TOPIC}/${ID}/$1/rx -m $result_rx
mosquitto_pub -t ${TOPIC}/${ID}/$1/tx -m $result_tx

}

while [ 2 -gt 1 ]
do
stats $WAN1
sleep 7
done

### bw2mqtt.sh ###
##
#
