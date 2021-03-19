#!/bin/bash

declare -A raidSerialMap
serialGrepStr=""

while IFS="|" read -r serial label
do
  raidSerialMap[$serial]=$label
  serialGrepStr+="$serial\|"
done < raid1_mappings.txt

len=${#serialGrepStr}
serialGrepStr=${serialGrepStr::len-2}

declare -A raidPathMap
while read -r path serial
do
  raidPathMap[$path]=${raidSerialMap[$serial]}
done < <(lsblk -r -o PATH,SERIAL|grep -e "$serialGrepStr")

for key in "${!raidPathMap[@]}"
do
mkdir -p /raid1/${raidPathMap[$key]}
mount "$key" "/raid1/${raidPathMap[$key]}"
done

apt-get -y update && sudo apt-get -y upgrade 
apt-get install samba

mkdir -p /config/snapraid
cp *.conf /config/snapraid

useradd snapraid
docker pull xagaba/snapraid
