#!/bin/bash

cwd="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"

creds="${cwd}/src/miscellaneous/inventory/credentials"
[ -d "${creds}" ] && sudo rm -rf "${creds}"

docker build . -t k8s-on-gce/tools

if [ $? -eq 0 ]; then
    docker rm -f k8s-on-gce-tools 
    
    docker run -it \
        -v $PWD/src:/root/src \
        -v $HOME/.ssh:/root/.ssh \
        -p 8001:8001 \
        --name k8s-on-gce-tools k8s-on-gce/tools
fi
