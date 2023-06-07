#!/bin/sh

### bw2mqtt.sh ###

name="RT1"
id=lan_rt1
devlist="wan eth0"
topic=wrt2mqtt
interval=5
rxlimit=1500
txlimit=1500

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

### ### ###

function home()
{
icon=$2
dev=$4
devx=$(echo $4 | sed 's/\./_/g')
##
$mqttpub -r -t "homeassistant/sensor/${id}/${devx}_${1}/config" \
-m '{
 "unit_of_measurement":"kB/s",
 "state_class":"measurement",
 "expire_after":"300",
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
##
$mqttpub -r -t "homeassistant/sensor/${id}/${devx}_${1}_limit/config" \
-m '{
 "unit_of_measurement":"kB/s",
 "state_class":"measurement",
 "expire_after":"300",
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
##
}

### ### ###

function stats()
{
getbytes=""; getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxaa=$(echo "$getbytes" | awk '{ print $3 }')
txaa=$(echo "$getbytes" | awk '{ print $8 }')

sleep $interval

getbytes=""; getbytes=$(ifconfig $1 | grep bytes: | sed 's/:/\ /g')
rxbb=$(echo "$getbytes" | awk '{ print $3 }')
txbb=$(echo "$getbytes" | awk '{ print $8 }')

if [ $rxbb -lt $rxaa ]
then
rxbb=$rxaa
fi

if [ $txbb -lt $txaa ]
then
txbb=$txaa
fi

result_rx=""; result_rx=$( expr $(expr $rxbb - $rxaa) / 1024 / $interval )
result_tx=""; result_tx=$( expr $(expr $txbb - $txaa) / 1024 / $interval )

$mqttpub -t $topic/${id}/${devx}_rx -m $result_rx
$mqttpub -t $topic/${id}/${devx}_tx -m $result_tx

if [ $result_rx -gt $rxlimit ]
then
result_rx=$rxlimit
fi

if [ $result_tx -gt $txlimit ]
then
result_tx=$txlimit
fi

devx=$(echo $1 | sed 's/\./_/g')

$mqttpub -t $topic/${id}/${devx}_rx_limit -m $result_rx
$mqttpub -t $topic/${id}/${devx}_tx_limit -m $result_tx

}

### ### ###
### ### ###

if [ $1 ]
then
devlist=$1
else
##
for dev in $devlist
do
home rx mdi:arrow-down RX $dev
home tx mdi:arrow-up TX $dev
done
##
$mqttpub -r -t "homeassistant/binary_sensor/${id}/${id}_status/config" \
-m '{
 "device_class":"connectivity",
 "payload_on":"online",
 "payload_off":"offline",
 "expire_after":"300",
 "name":"'"$name Status"'",
 "state_topic":"'"$topic/${id}/status"'",
 "availability_topic":"'$topic/${id}/status'",
 "unique_id":"'"${id}_status"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
}'
##
fi

### ### ###
### ### ###

$mqttpub -t $topic/${id}/status -m online

for dev in $devlist
do
stats $dev
done

### ### ###
### ### ###

for dev in $devlist
do
/bin/sh $0 $dev &
done

### bw2mqtt.sh ###
##
#
