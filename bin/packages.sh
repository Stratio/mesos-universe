#!/bin/bash -e

BASEDIR=`dirname $0`/..

cd docker/local-universe && make base && make local-universe
