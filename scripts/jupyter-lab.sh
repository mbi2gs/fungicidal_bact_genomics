#!/usr/bin/env bash

while :
do
        PORT="`shuf -i 8888-9999 -n 1`"
        ss -lpn | grep -q ":$PORT " || break
done

while getopts 'p:' opt
    do
        case $opt in
            p) PORT=$OPTARG;;
        esac
done

docker run \
    -d --rm  \
	-e "NB_UID=$UID" --user root \
    -e "GRANT_SUDO=yes" \
    -e DATA_DIR \
    -e IMG_DIR \
    --name fungicidal_bact_genomics_$(hostname)_$(id -u) \
    -w $PWD \
    -v $PWD:$PWD \
    -p $PORT:$PORT \
    fungicidal_bact_genomics start.sh jupyter lab --allow-root --port $PORT
