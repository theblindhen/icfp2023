#!/bin/zsh

# For human-readable large numbers
export LC_ALL=en_US.UTF-8

TOTAL_IMPROVEMENT_K=0
for p in {1..90}; do
  if [ -d problems/solutions-$p ]; then
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
      TOTAL_IMPROVEMENT_K=$((TOTAL_IMPROVEMENT_K + IMPROVEMENT / 1000))
      printf "$p: improved by %'.0f $NEW_SOLUTION\n" "$IMPROVEMENT"
    fi;
    popd
  else
    echo "$p : No solution!"
  fi;
done
echo
printf "Total improvement: %'.0f thousands\n" "$TOTAL_IMPROVEMENT_K"
