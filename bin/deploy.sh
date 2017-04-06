#!/bin/bash -e

BASEDIR=`dirname $0`/..
VERSION=`cat $BASEDIR/VERSION`

# Only upload offline universe in case of release
if [[ ${JOB_NAME} == Release* ]]; then
	# Upload offline universe
	echo "---> Uploading offline universe"
	cd docker/local-universe && curl -sS -u stratio:${NEXUSPASS} --upload-file local-universe-${VERSION}.tar.gz http://sodio.stratio.com/repository/paas/offline-universe/mesos/

	# Upload consul offline universe
	echo "---> Uploading consul offline universe"
	cd docker/local-universe && curl -sS -u stratio:${NEXUSPASS} --upload-file local-consul-universe-${VERSION}.tar.gz http://sodio.stratio.com/repository/paas/offline-universe/mesos/
fi
