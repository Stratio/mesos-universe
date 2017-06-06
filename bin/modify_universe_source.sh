#!/bin/bash -e

SOURCE=$1
NAME_ADDITION=$2

# modify docker/local-universe/Makefile
sed -e "s/master.mesos/$SOURCE/g" -e "s/local-universe/local-$NAME_ADDITION-universe/g" -i docker/local-universe/Makefile

# modify scripts/local-universe.py
sed "s/master.mesos/$SOURCE/g" -i scripts/local-universe.py
