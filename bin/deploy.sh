#!/bin/bash -e

BASEDIR=`dirname $0`/..
VERSION=`cat $BASEDIR/VERSION`

cd docker/local-universe && curl -sS -u stratio:${NEXUSPASS} --upload-file local-universe-${VERSION}.tar.gz http://sodio.stratio.com/nexus/content/sites/paas/offline-universe/mesos/
