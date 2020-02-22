#!/bin/sh

docker stop dosbox
docker rm dosbox
docker run -it --name dosbox --privileged fransking/dosbox-armv7l /bin/sh
