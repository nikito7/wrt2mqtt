#!/bin/sh

### bw2mqtt.sh ###

name="WAN"
id=wan_rt1
devlist="eth0.2 eth5 eth7"
topic=wrt2mqtt
mqttpub="mosquitto_pub -h 10.1.0.1 -k 5 -i $id"
interval=1
limit=999
model=$(cat /proc/cpuinfo | grep machine | awk '{ print $3 }')

###

function home()
{
icon=$2
dev=$4
devx=$(echo $4 | sed 's/\./_/g')
#
$mqttpub -t "homeassistant/sensor/${id}/${devx}_${1}/config" \
-m '{
 "unit_of_measurement":"kB/s",
 "icon":"'$icon'",
 "name":"'"$name $dev $3"'",
 "state_topic":"'"$topic/${id}/${devx}_${1}"'",
 "unique_id":"'"${id}_${devx}_$1"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
 }'
#
}

###

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

sleep $interval

getbytes=""; getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxbb=$(echo "$getbytes" | awk '{ print $3 }')
txbb=$(echo "$getbytes" | awk '{ print $8 }')

result_rx=""; result_rx=$( expr $(expr $rxbb - $rxaa) / 1024 / $interval )
result_tx=""; result_tx=$( expr $(expr $txbb - $txaa) / 1024 / $interval )

if [ $result_rx -gt $limit ]
then
result_rx=$limit
fi

if [ $result_tx -gt $limit ]
then
result_tx=$limit
fi

devx=$(echo $1 | sed 's/\./_/g')

$mqttpub -t $topic/${id}/${devx}_rx -m $result_rx
$mqttpub -t $topic/${id}/${devx}_tx -m $result_tx

}

for dev in $devlist
do
stats $dev
done

###

sleep $interval && /bin/sh $0 &

### bw2mqtt.sh ###
##
#
