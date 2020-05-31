# dosbox
Raspberry Pi docker image for dosbox

## Quick Start

This container image is available from the Docker Hub.

Assuming that you have Docker installed, run the following command:

````bash
docker run -d \
        -p 3389:3389 \
        -p 5900:5900 \
        --name dosbox \
        --privileged fransking/dosbox-arm32v7:latest
````

priviledged mode is needed if you want to enable GPU acceleration

## License 

This project is licensed under the [BSD 2-Clause License](LICENSE).
