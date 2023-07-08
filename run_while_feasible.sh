#!/bin/zsh
TIMEOUT=10m
PROBLEM=$1
BIN=./_build/default/bin/main.exe
rm -f _bailed_$1
pushd contest
while timeout $TIMEOUT $BIN $1 --lp --edges "$(./../random_edges.sh)"; do
    echo "-- Retrying $1 --"
done
popd
touch _bailed_$1
