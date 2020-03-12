#!/bin/sh

docker stop dosbox
docker rm dosbox
docker run -d -p 3389:3389 -p 5900:5900 --name dosbox --privileged fransking/dosbox-arm32v7:latest
