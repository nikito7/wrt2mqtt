#!/bin/sh

### ping2mqtt.sh ###

name="WAN"
id=wan_rt1
devlist="eth5 eth7"
topic=wrt2mqtt
host=8.8.8.8
interval=10
limit=299
mqttpub="mosquitto_pub"
model=$(cat /proc/cpuinfo | grep machine | awk '{ print $3 }')

###

$mqttpub -t $topic/${id}/status -m online

if [ $1 ]
then
devlist=$1
fi

###

function home()
{
icon=$2
dev=$4
devx=$(echo $4 | sed 's/\./_/g')
#
$mqttpub -t "homeassistant/sensor/${id}/${devx}_${1}/config" \
-m '{
 "unit_of_measurement":"ms",
 "expire_after":"15",
 "icon":"'$icon'",
 "name":"'"$name $dev $3"'",
 "state_topic":"'"$topic/${id}/${devx}_${1}"'",
 "availability_topic":"'$topic/${id}/status'",
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
home ping mdi:clock Ping $dev
done

###

$mqttpub -t "homeassistant/binary_sensor/${id}/${id}_status/config" \
-m '{
 "device_class":"connectivity",
 "payload_on":"online",
 "payload_off":"offline",
 "expire_after":"15",
 "name":"'"$name Status"'",
 "state_topic":"'"$topic/${id}/status"'",
 "availability_topic":"'$topic/${id}/status'",
 "unique_id":"'"${id}_status"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
}'

###

function stats()
{

sleep $interval

ping_result="-1"

ping_result=$(ping -c 1 -W 1 -I $1 $host | grep time | awk -F "time=" '{ print $2 }' | awk -F . '{ print $1 }')   

devx=$(echo $1 | sed 's/\./_/g')

if [ $ping_result -gt $limit ]
then
ping_result=$limit
fi

$mqttpub -t $topic/${id}/${devx}_ping -m $ping_result

}

for dev in $devlist
do
stats $dev
done

###

for dev in $devlist
do
/bin/sh $0 $dev &
done

### ping2mqtt.sh ###
##
#
