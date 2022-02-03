#!/bin/sh

name="EB Discovery"
id=eb_discovery
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
 "name":"Status",
 "state_topic":"tele/edpbox1/LWT",
 "availability_topic":"tele/edpbox1/LWT",
 "unique_id":"'"${id}_status"'",
 "device":{
   "identifiers":"'${id}'",
   "name":"'"$name"'",
   "model":"'"$model"'"}
}'

$mqttpub -t "homeassistant/sensor/${id}/xxxx/config" \
-m '{
 "unit_of_measurement":"ms",
 "icon":"mdi:chip",
 "name":"xxxxx",
 "state_topic":"tele/edpbox1/STATE",
 "value_template":"{{ ( value_json.UptimeSec / 3600 ) | round(1) }}",
 "unique_id":"'"${id}_xxxxx"'",
 "device":{
   "identifiers":"'${id}'"}
}'

#
