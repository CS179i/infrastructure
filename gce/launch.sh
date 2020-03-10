#!/bin/bash
#
# GCE image launch script that ensures that the correct containers are running.
# 
# Maintainer: Nick Pleatsikas <nick@pleatsikas.me>

git clone https://github.com/opa-social/infrastructure.git
cd infrastructure/gce || return

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose:1.25.4 up -d