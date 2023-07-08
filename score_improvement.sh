#!/bin/zsh
for p in {1..55}; do
  if [ -d problems/solutions-$p ]; then
    echo $p
    pushd problems/solutions-$p;
    # Files are <score>.json
    # Submitted solutions are <score>.json.submitted
    # Print the best score and previous best score
    BEST=$(ls | grep '^[0-9]*[.]json$' | sed 's/[.]json$//' | sort -n | tail -n 1);
    # If there are any submitted
    if [ -n "$(ls | grep '^[0-9]*[.]json[.]submitted$')" ]; then
      # Print the best submitted score
      BEST_SUBMITTED=$(ls | grep '^[0-9]*[.]json[.]submitted$' | sed 's/[.]json[.]submitted$//' | sort -n | tail -n 1);
      NEW_SOLUTION="";
    else
      # Otherwise, print 0
      BEST_SUBMITTED=0;
      NEW_SOLUTION="  new solution!";
    fi;
    # If BEST is better than BEST_SUBMITTED then print
    if [ "$BEST" -gt "$BEST_SUBMITTED" ]; then
      IMPROVEMENT=$(($BEST - $BEST_SUBMITTED));
      echo "$p: improved by $IMPROVEMENT $NEW_SOLUTION"
    fi;
    popd
  else
    echo "$p : No solution!"
  fi;
done