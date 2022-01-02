#!/bin/bash

setup_samba () {

cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
touch  /etc/samba/includes.conf
echo "include = /etc/samba/includes.conf" >> /etc/samba/smb.conf
mkdir /etc/samba/includes
cp smb.conf /etc/samba/includes/drive_share_mappings.conf
ls /etc/samba/includes/* | sed -e 's/^/include = /' > /etc/samba/includes.conf
service smbd restart

}

setup_snapraid () {

mkdir -p /media/pool	
mkdir -p /config/snapraid
cp *.conf /config/snapraid

useradd snapraid
docker pull xagaba/snapraid

}

build_drive_mappings () {

declare -A raidSerialMap
serialGrepStr=""

while IFS="|" read -r serial label
do
  raidSerialMap[$serial]=$label
  serialGrepStr+="$serial\|"
done < $1

len=${#serialGrepStr}
serialGrepStr=${serialGrepStr::len-2}

declare -A raidPathMap
while read -r path serial
do
  raidPathMap[$path]=${raidSerialMap[$serial]}
done < <(lsblk -r -o PATH,SERIAL|grep -e "$serialGrepStr")

for key in "${!raidPathMap[@]}"
do
mkdir -p /$2/${raidPathMap[$key]}
mount "$key" "/$2/${raidPathMap[$key]}"
done

}

prereq_docker () {

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable"
}

prereq_webmin () {

wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
add-apt-repository "deb http://download.webmin.com/download/repository sarge contrib"

}

build_drive_mappings raid1_mappings.txt raid1

apt-get -y update && sudo apt-get -y upgrade 
apt-get -y install \
	samba \
        smbclient \
        software-properties-common \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
        lsb-release \
        cockpit \
        net-tools 
        
prereq_docker
prereq_webmin

apt-get -y update
apt-get -y install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
        webmin

setup_snapraid
setup_samba

