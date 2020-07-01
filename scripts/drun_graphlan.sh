#!/usr/bin/env bash

docker run  \
    -w ${PWD} \
    -v ${PWD}:${PWD} \
    -e UID \
    graphlan_cntnr $@
