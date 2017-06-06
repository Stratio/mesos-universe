#!/bin/bash -e

BASEDIR=`dirname $0`/..
VERSION=`cat $BASEDIR/VERSION`

# Only generate offline universe in case of release
if [[ ${JOB_NAME} == Release* ]]; then
	# Install socat
	sudo apt-get update && sudo apt-get install socat
	# Setup socat
	sudo nohup socat TCP-LISTEN:5000,fork TCP:jenkins.stratio.com:5000 &

	# Create offline universe
	echo "---> Creating offline universe"
	cd docker/local-universe && sudo DOCKER_HOST="jenkins.stratio.com:12375" make base && sudo DOCKER_HOST="jenkins.stratio.com:12375" make local-universe 2>&1 | tee /tmp/mesos_offline_universe_generation
	if [[ ! -z `cat /tmp/mesos_offline_universe_generation | grep "These packages are not included in the image"` ]]; then
        	exit -1
	fi

	# Rename offline universe to add version
	mv local-universe.tar.gz local-universe-${VERSION}.tar.gz
	sudo chmod 777 local-universe-${VERSION}.tar.gz

	# Remove universe directory
	sudo rm -Rf universe http registry

	# Modify to create consul universe
	echo "---> Modifying scripts for consul offline universe generation"
	cd ../..
	bin/modify_universe_source.sh universe.service.consul consul

	# Create consul offline universe
	echo "---> Creating consul offline universe"
	cd docker/local-universe && sudo DOCKER_HOST="jenkins.stratio.com:12375" make base && sudo DOCKER_HOST="jenkins.stratio.com:12375" make local-universe 2>&1 | tee /tmp/mesos_offline_consul_universe_generation
        if [[ ! -z `cat /tmp/mesos_offline_consul_universe_generation | grep "These packages are not included in the image"` ]]; then
                exit -1
        fi

	# Rename consul offline universe to add version
	mv local-consul-universe.tar.gz local-consul-universe-${VERSION}.tar.gz
	sudo chmod 777 local-consul-universe-${VERSION}.tar.gz

	# Modify to original value
        echo "---> Modifying scripts to original value"
        cd ../..
        bin/modify_consul_universe_source.sh master.mesos

	
	# kill socat connection
	sudo kill -9 $(pidof socat)
	
	# Force successful exit
	exit 0
fi
