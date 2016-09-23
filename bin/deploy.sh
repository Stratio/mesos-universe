#!/bin/bash -e

BASEDIR=`dirname $0`/..
cd docker/local-universe && curl -sS -u stratio:${NEXUSPASS} --upload-file local-universe.tar.gz http://sodio.stratio.com/nexus/content/sites/paas/offline-universe/mesos/
