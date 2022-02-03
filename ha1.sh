#!/bin/sh

name="ha super device"
id=ha_device_001
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

$mqttpub -t "homeassistant/binary_sensor/${id}/${id}_status/config" \
-m '{
 "device_class":"connectivity",
 "payload_on":"online",
 "payload_off":"offline",
 "name":"'"$name Status"'",
 "state_topic":"'"tele/edpbox1/LWT"'",
 "availability_topic":"'tele/edpbox1/LWT'",
 "unique_id":"'"${id}_status"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
}'

