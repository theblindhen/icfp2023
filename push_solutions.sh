#!/bin/bash
if [ -z $APIKEY ]; then
    echo "Please set your APIKEY environment variable."
    exit 1
fi
for i in {1..45}; do
    if [ -d problems/solutions-$i ]; then
        if [ -n "$(ls problems/solutions-$i)" ]; then
            SMALLEST=$(cd problems/solutions-$i/; ls * | sort -n | head -1)
            if [ ! -f problems/solutions-$i/$SMALLEST.submitted ]; then
                if
                    echo "Submitting solutions-$i/$SMALLEST"
                    jq '{"problem_id": '$i', "contents": .|tojson}' problems/solutions-$i/$SMALLEST \
                    | curl -L -sS -X POST \
                        -H "Authorization: Bearer $APIKEY" \
                        --json @- \
                        https://api.icfpcontest.com/submission \
                    | tee /dev/stderr \
                    | grep -q '"........................"'
                then
                    echo
                    touch problems/solutions-$i/$SMALLEST.submitted
                    git add problems/solutions-$i/$SMALLEST
                    git add problems/solutions-$i/$SMALLEST.submitted
                fi
            fi
        fi
    fi
done
