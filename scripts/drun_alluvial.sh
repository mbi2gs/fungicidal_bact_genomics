#!/usr/bin/env bash

docker run  \
    -w ${PWD} \
    -v ${PWD}:${PWD} \
    -e UID \
    alluvial_cntnr $@