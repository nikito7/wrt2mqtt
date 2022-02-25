#!/bin/sh

### ping2mqtt.sh ###

name="RT 1"
id=lan_rt_1
devlist="wan eth0"
topic=wrt2mqtt
host=1.1.1.1
count=5
interval=30
limit=100

### global code ###

secrets=/root/secrets.sh

function get()
{
cat $secrets | grep $1 | awk -F "=" '{ print $2 }'
}

model=$(cat /proc/cpuinfo | grep machine | awk -F ":" '{ print $2 }')
mqttpub="mosquitto_pub -h \
$(get server) -u \
$(get user) -P \
$(get pass)"

###

$mqttpub -t $topic/${id}/status -m online

if [ $1 ]
then
devlist=$1
sleep $interval
fi

###

function homeconf()
{
icon=$2
dev=$4
devx=$(echo $4 | sed 's/\./_/g' | sed 's/-/_/g')
#
$mqttpub -t "homeassistant/sensor/${id}/${devx}_${1}/config" \
-m '{
 "unit_of_measurement":"ms",
 "state_class":"measurement",
 "expire_after":"120",
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
$mqttpub -t "homeassistant/sensor/${id}/${devx}_${1}_limit/config" \
-m '{
 "unit_of_measurement":"ms",
 "state_class":"measurement",
 "expire_after":"120",
 "icon":"'$icon'",
 "name":"'"$name $dev $3 L"'",
 "state_topic":"'"$topic/${id}/${devx}_${1}_limit"'",
 "availability_topic":"'$topic/${id}/status'",
 "unique_id":"'"${id}_${devx}_${1}_limit"'",
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
homeconf ping mdi:gauge Ping $dev
done

###

$mqttpub -t "homeassistant/binary_sensor/${id}/${id}_status/config" \
-m '{
 "device_class":"connectivity",
 "payload_on":"online",
 "payload_off":"offline",
 "expire_after":"120",
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

ping_result="-1"

ping_result=$(ping -c $count -I $1 $host | grep trip | awk -F / '{ print $4 }' | awk -F . '{ print $1 }')   

devx=$(echo $1 | sed 's/\./_/g' | sed 's/-/_/g')

$mqttpub -t $topic/${id}/${devx}_ping -m $ping_result

if [ "$ping_result" -gt "$limit" ]
then
ping_result=$limit
fi

$mqttpub -t $topic/${id}/${devx}_ping_limit -m $ping_result

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
