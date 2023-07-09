#!/bin/zsh
rm -f _bailed_*

set -e
PROCESSES=$(nproc)

(cd contest && dune build _build/default/bin/main.exe)
seq 1 $PROCESSES | xargs -P "$PROCESSES" -I{} ./run_while_feasible.sh $*
