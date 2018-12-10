#!/bin/bash

DIRNAME="$(dirname $(readlink -f "$0"))"
pushd ${DIRNAME}

./cleanup_registry_digests.sh

docker-compose run --rm registry bin/registry garbage-collect /etc/docker/registry/config.yml
