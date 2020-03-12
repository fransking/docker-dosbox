#!/bin/bash


docker build -t fransking/dosbox-arm32v7 .
docker image inspect fransking/dosbox-arm32v7:latest --format='{{.Size}}'
