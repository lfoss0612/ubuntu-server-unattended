
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
sudo mkdir -p /raid1/${raidPathMap[$key]}
sudo mount "$key" "/raid1/${raidPathMap[$key]}"
done

sudo apt-get -y update && sudo apt-get -y upgrade 
sudo apt-get install gcc make samba

sudo mkdir /var/lib/snapraid 
sudo chmod a+w /var/lib/snapraid 
cd /var/lib/snapraid

wget https://github.com/amadvance/snapraid/releases/download/v11.5/snapraid-11.5.tar.gz 
tar -xzf snapraid-11.5.tar.gz 
cd snapraid-11.5
./configure 

make 
make check 
sudo make install 

cd ~ && rm /var/lib/snapraid/snapraid-11.5.tar.gz
