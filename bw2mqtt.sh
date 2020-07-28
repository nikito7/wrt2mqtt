#!/bin/sh

### bw2mqtt.sh ###

name="Router 1"
id=rt01
devlist="eth0.2 eth5 eth7"
topic=wrt2mqtt

###

devlistx=$(echo $devlist | sed 's/\./_/g')

for dev in $devlistx
do
for n in rx tx
do
mosquitto_pub -t "homeassistant/sensor/$id/${dev}_${n}/config" \
-m "{\"unit_of_measurement\":\"kB/s\",\
 \"icon\":\"mdi:arrow\",\
 \"name\":\"$id $dev $n\",\
 \"state_topic\":\"$topic/$id/$dev/$n\",\
 \"availability_topic\":\"$topic/$id/status\",\
 \"unique_id\":\"$id-$dev-$n\",\
 \"device\":{\
 \"identifiers\":\"$id\",\
 \"name\":\"$id\",\
 \"sw_version\":\"v0\",\
 \"model\":\"x\",\
 \"manufacturer\":\"x\"}}"
done
done

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

devx=$(echo $1 | sed 's/\./_/g')

mosquitto_pub -t $topic/$id/status -m online
mosquitto_pub -t $topic/$id/$devx/rx -m $result_rx
mosquitto_pub -t $topic/$id/$devx/tx -m $result_tx

}

while [ 2 -gt 1 ]
do
for dev in $devlist
do
stats $dev
done
sleep 7
done

### bw2mqtt.sh ###
##
#
