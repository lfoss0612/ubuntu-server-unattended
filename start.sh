
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

sudo mkdir /raid1

for key in "${!raidPathMap[@]}"
do
sudo mkdir /raid1/${raidPathMap[$key]}
echo $key
sudo mount "$key" "/raid1/${raidPathMap[$key]}"
done

