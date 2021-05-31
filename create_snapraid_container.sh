#!/bin/bash

docker create \
-v /mnt:/mnt \
-v /config/snapraid:/config \
-v /raid1:/raid1 \
-v /media:/media \
-e PGID=1001 -e PUID=1001 \
--privileged \
--mount type=bind,source=/dev/disk,target=/dev/disk \
--name snapraid \
xagaba/snapraid
