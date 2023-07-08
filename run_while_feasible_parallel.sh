#!/bin/zsh
PROCESSES=$1
pushd contest; dune build _build/default/bin/main.exe; popd
seq 56 90 | xargs -n 1 -P $1 ./run_while_feasible.sh
