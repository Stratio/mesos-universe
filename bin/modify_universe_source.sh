#!/bin/bash -e

SOURCE=$1
NAME_ADDITION=$2

# modify paas-universe/docker/local-universe/Makefile
sed -e "s/master.mesos/$SOURCE/g" -e "s/local-paas-universe/local-paas-$NAME_ADDITION-universe/g" -i paas-universe/docker/local-universe/Makefile

# modify paas-universe/scripts/local-universe.py
sed "s/master.mesos/$SOURCE/g" -i paas-universe/scripts/local-universe.py
