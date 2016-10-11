#!/bin/bash -e

BASEDIR=`dirname $0`/..

cd docker/local-universe && make base && make local-universe 2>&1 > /tmp/mesos_offline_universe_generation
cat /tmp/mesos_offline_universe_generation
if [[ ! -z `cat /tmp/mesos_offline_universe_generation | grep "These packages are not included in the image"` ]]; then
        exit -1
fi
