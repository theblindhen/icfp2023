#!/bin/zsh
TIMEOUT=10m
PROBLEM=$1
BIN=./_build/default/bin/main.exe
rm -f _bailed_$1
pushd contest
while timeout 10s $BIN --lp $1; do
    echo "-- Retrying $1 --"
done
popd
touch _bailed_$1