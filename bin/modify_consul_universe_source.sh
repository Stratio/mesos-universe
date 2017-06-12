#!/bin/bash -e

SOURCE=$1

# modify docker/local-universe/Makefile
sed -e "s/universe.service.consul/$SOURCE/g" -e "s/local-consul-universe.tar/local-universe.tar/g" -i docker/local-universe/Makefile

# modify scripts/local-universe.py
sed "s/universe.service.consul/$SOURCE/g" -i scripts/local-universe.py
