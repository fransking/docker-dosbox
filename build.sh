#!/bin/bash


docker build -t fransking/dosbox-armv7l .
docker image inspect fransking/dosbox-armv7l:latest --format='{{.Size}}'
