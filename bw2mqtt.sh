#!/bin/sh

### bw2mqtt.sh ###

NAME=router1
ID=router10101
WAN1=eth0.2
TOPIC=wrt2mqtt

###

mosquitto_pub -t homeassistant/sensor/${NAME}/bw/rx/config \
-m "{\
\"unit_of_measurement\\":\"kB/s\",\
\"icon\":\"mdi:signal\",\
\"name\":\"$NAME BW RX\",\
\"state_topic\":\"${TOPIC}/${NAME}/bw/rx/state\",\
\"unique_id\":\"$ID-bw-rx\",\
\"device\":{\
\"identifiers\":\"$ID\",\
\"name\":\"$NAME\"}\
}\
"

mosquitto_pub -t homeassistant/sensor/${NAME}/bw/tx/config \
-m "{ test }"

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

mosquitto_pub -t ${TOPIC}/${NAME}/bw/rx/state -m $result_rx
mosquitto_pub -t ${TOPIC}/${NAME}/bw/tx/state -m $result_tx

}

stats $WAN1

### bw2mqtt.sh ###
##
#
