#!/bin/bash -e

BASEDIR=`dirname $0`/..

cd docker/local-universe && sudo make base && sudo make local-universe
