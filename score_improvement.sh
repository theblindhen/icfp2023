#!/bin/zsh
for p in {1..55}; do
  if [ -d problems/solutions-$p ]; then
    echo $p
    pushd problems/solutions-$p;
    # Files are <score>.json
    # Submitted solutions are <score>.json.submitted
    # Print the best score and previous best score
    BEST=$(ls | grep '^[0-9]*[.]json$' | sed 's/[.]json$//' | sort -n | tail -n 1);
    BEST_SUBMITTED=$(ls | grep '^[0-9]*[.]json[.]submitted$' | sed 's/[.]json[.]submitted$//' | sort -n | tail -n 1);
    # If BEST is better than BEST_SUBMITTED then print
    if [ "$BEST" -gt "$BEST_SUBMITTED" ]; then
      IMPROVEMENT=$(($BEST - $BEST_SUBMITTED));
      echo "$p  :  $IMPROVEMENT"
    fi;
    popd
  else
    echo "$p : No solution!"
  fi;
done