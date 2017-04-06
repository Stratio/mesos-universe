#!/bin/bash -e

if [[ -d paas-universe/target ]]; then
	rm -Rf paas-universe/target
fi

if [[ -d target ]]; then
	rm -Rf target
fi

if [[ -d env-ut ]]; then
	rm -Rf env-ut
fi
