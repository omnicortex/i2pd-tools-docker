#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=i2pd-tools
containerid=$project-$randstr
imageid=$project-$(id -u)

(set -xe; podman build -t $imageid .)
