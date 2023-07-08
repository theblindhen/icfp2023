#!/bin/zsh
TIMEOUT=10s
PROBLEM=$1
BIN=./_build/default/bin/main.exe
pushd contest
while timeout 10s $BIN --lp $1; do
    echo "-- Retrying $1 --"
done
popd