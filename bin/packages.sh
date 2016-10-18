#!/bin/bash -e

BASEDIR=`dirname $0`/..
VERSION=`cat $BASEDIR/VERSION`

cd docker/local-universe && make base && make local-universe 2>&1 > /tmp/mesos_offline_universe_generation
cat /tmp/mesos_offline_universe_generation
if [[ ! -z `cat /tmp/mesos_offline_universe_generation | grep "These packages are not included in the image"` ]]; then
        exit -1
fi

# Rename offline universe to add version
mv local-universe.tar.gz local-universe-${VERSION}.tar.gz
