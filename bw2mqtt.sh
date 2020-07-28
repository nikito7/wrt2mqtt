#!/bin/sh

### bw2mqtt.sh ###

name="Router 1"
id=rt_10_1_0_1
devlist="eth0.2 eth5 eth7"
topic=wrt2mqtt
mqttpub="mosquitto_pub"
###

function home()
{
icon=$2
dev=$4
devx=$(echo $4 | sed 's/\./_/g')
#
$mqttpub -t "homeassistant/sensor/$id/${devx}_${1}/config" \
-m '{
 "unit_of_measurement":"kB/s",
 "icon":"'$icon'",
 "name":"'"$name $dev $3"'",
 "state_topic":"'"$topic/$id/${devx}_${1}"'",
 "availability_topic":"'$topic/$id/status'",
 "unique_id":"'"${id}_${devx}_$1"'",
 "device":{
   "identifiers":"'$id'",
   "name":"'"$name"'",
   "sw_version":"v0",
   "model":"x",
   "manufacturer":"x"}
 }'
#
}

for dev in $devlist
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

$mqttpub -t $topic/$id/status -m online
$mqttpub -t $topic/$id/${devx}_rx -m $result_rx
$mqttpub -t $topic/$id/${devx}_tx -m $result_tx

}

for dev in $devlist
do
stats $dev
done

sleep 15 && /bin/sh $0 &

### bw2mqtt.sh ###
##
#
