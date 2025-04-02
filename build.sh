#!/bin/bash

pushd $(dirname $0)

if [ -z "$LOGIN" ]; then
	echo "LOGIN is not defined"
	exit 1
fi

git submodule update --init

pushd frr/docker/debian
	docker build -t 'frr:debian' .
popd

build() {
	docker build -t "$2"_"$LOGIN":"$1" -f "$1"/"$2"_ "$1"
}

build P1 host
build P1 router

build P2 host
build P2 router

build P3 host
build P3 router

popd
