#!/bin/bash -e

BASEDIR=`dirname $0`/..
VERSION=`cat $BASEDIR/VERSION`

# Create normal universe image
cd scripts && ./build.sh && cd ..

# Create offline universe
echo "---> Creating offline universe"
cd docker/local-universe && sudo make base && sudo make local-universe 2>&1 | tee /tmp/mesos_offline_universe_generation

if [[ ! -z `cat /tmp/mesos_offline_universe_generation | grep "These packages are not included in the image"` ]]; then
       	exit -1
fi

# Rename offline universe to add version
mv local-universe.tar.gz local-universe-${VERSION}.tar.gz
sudo chmod 777 local-universe-${VERSION}.tar.gz

# Force successful exit
exit 0
