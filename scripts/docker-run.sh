#!/usr/bin/env bash

docker run  \
    -w ${PWD} \
    -v ${PWD}:${PWD} \
    --user root -e "NB_UID=${UID}" \
    fungicidal_bact_genomics \
    start.sh $@
