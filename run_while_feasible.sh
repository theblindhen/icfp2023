#!/bin/zsh
TIMEOUT=10m
BIN=./_build/default/bin/main.exe
pushd contest
while true; do
    for i in $(shuf -e $*); do
        if [ -f "../_bailed_$i" ]; then
            continue
        fi
        edges="$(./../random_edges.sh)"
        echo "Trying $i with edges '$edges'"
        if ! timeout $TIMEOUT $BIN $i --lp --edges "$edges"; then
            echo "Bailed on $i"
            touch "../_bailed_$i"
        fi
    done
done
popd
