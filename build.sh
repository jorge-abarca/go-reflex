#!/usr/bin/env bash

if [ -n "${APT_INSTALL}" ]; then
    apt-get update && apt-get install -y "${APT_INSTALL}"
fi

if [[ ${DEBUG} -eq "1" ]]; then
	args=(-gcflags "all=-N -l" -o /go/bin/app)
else
    args=(-o /go/bin/app)
fi


if [[ ${RACE_DETECTOR} -eq "1" ]]; then
	CGO_ENABLED=1
    args+=(-race)
fi

cd /app
go build "${args[@]}" ${BUILD_ARGS}

if [[ ${DEBUG} -eq "1" ]]; then
	/dlv --headless --listen=:40000 --api-version=2 --log=false exec /go/bin/app ${RUN_ARGS}
else
    /go/bin/app ${RUN_ARGS}
fi