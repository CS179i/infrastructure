#!/bin/bash
#
# GCE image launch script that ensures that the correct containers are running.
# 
# Maintainer: Nick Pleatsikas <nick@pleatsikas.me>

cat <<EOF > ~/firebase-config.json
{
  "projectId": "opa-268409",
  "databaseURL": "https://opa-268409.firebaseio.com/"
}
EOF

export FIREBASE_CONFIG=~/firebase-config.json

git clone https://github.com/opa-social/infrastructure.git
cd infrastructure/gce || return

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose:1.25.4 up -d