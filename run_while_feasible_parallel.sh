#!/bin/zsh
PROCESSES=$1
pushd contest; dune build; popd
seq 1 90 | xargs -n 1 -P $1 ./run_while_feasible.sh