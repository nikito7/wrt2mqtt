#!/bin/sh

### ping2mqtt.sh ###

name="RT 90"
id=lan_rt_90
devlist="br-lan vpn1"
topic=wrt2mqtt
host=1.1.1.1
count=5
interval=30
limit=300
secrets=/root/secrets
skip_config=10

###

model=$(cat /proc/cpuinfo | grep machine | awk -F ":" '{ print $2 }')
mqttpub="mosquitto_pub -h \
cat $secrets | grep server | awk -F = '{ print $2 }' -u \
cat $secrets | grep user | awk -F = '{ print $2 }' -P \
cat $secrets | grep pass | awk -F = '{ print $2 }'"

###

$mqttpub -t $topic/${id}/status -m online

if [ $1 ]
then
devlist=$1
fi

if [ $2 ]
then
counter=$(( $2 + 1 ))
else
counter=0
fi

if [ $counter -gt $skip_config ]
then
counter=0
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
 "expire_after":"90",
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
 "expire_after":"90",
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

if [ $counter -eq 0 ]
then
for dev in $devlist
do
home ping mdi:gauge Ping $dev
done
fi

###

if [ $counter -eq 0 ]
then
$mqttpub -t "homeassistant/binary_sensor/${id}/${id}_status/config" \
-m '{
 "device_class":"connectivity",
 "payload_on":"online",
 "payload_off":"offline",
 "expire_after":"90",
 "name":"'"$name Status"'",
 "state_topic":"'"$topic/${id}/status"'",
 "availability_topic":"'$topic/${id}/status'",
 "unique_id":"'"${id}_status"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
}'
fi

###

function stats()
{

sleep $interval

ping_result="-1"

ping_result=$(ping -c $count -I $1 $host | grep trip | awk -F / '{ print $4 }' | awk -F . '{ print $1 }')   

devx=$(echo $1 | sed 's/\./_/g')

$mqttpub -t $topic/${id}/${devx}_ping -m $ping_result

if [ $ping_result -gt $limit ]
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
/bin/sh $0 $dev $counter &
done

### ping2mqtt.sh ###
##
#
