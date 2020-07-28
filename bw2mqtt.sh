#!/bin/sh

### bw2mqtt.sh ###

name="Router 1"
id=rt_10_1_0_1
devlist="eth0.2 eth5 eth7"
topic=wrt2mqtt

###

devlistx=$(echo $devlist | sed 's/\./_/g')

function home()
{
mosquitto_pub -t "homeassistant/sensor/$id/${4}_${1}/config" \
-m '{\"unit_of_measurement":"kB/s",\
 "icon":"$2",\
 "name":"$name $4 $3",\
 "state_topic":"$topic/$id/${4}_${1}",\
 "availability_topic":"$topic/$id/status",\
 "unique_id":"$id-$4-$1",\
 "device":{\
 "identifiers":"$id",\
 "name":"$name",\
 "sw_version":"v0",\
 "model":"x",\
 "manufacturer":"x"}}'
}

for dev in $devlistx
do
home rx mdi:arrow-down RX $dev
home tx mdi:arrow-up TX $dev
done

###

function stats()
{
getbytes=""; getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxaa=$(echo "$getbytes" | awk '{ print $3 }')
txaa=$(echo "$getbytes" | awk '{ print $8 }')

sleep 3

getbytes=""; getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxbb=$(echo "$getbytes" | awk '{ print $3 }')
txbb=$(echo "$getbytes" | awk '{ print $8 }')

result_rx=""; result_rx=$( expr $(expr $rxbb - $rxaa) / 1024 / 3 )
result_tx=""; result_tx=$( expr $(expr $txbb - $txaa) / 1024 / 3 )

echo RX $result_rx
echo TX $result_tx

devx=$(echo $1 | sed 's/\./_/g')

mosquitto_pub -t $topic/$id/status -m online
mosquitto_pub -t $topic/$id/${devx}_rx -m $result_rx
mosquitto_pub -t $topic/$id/${devx}_tx -m $result_tx

}

for dev in $devlist
do
stats $dev
done

sleep 9 && /bin/sh $0 &

### bw2mqtt.sh ###
##
#
