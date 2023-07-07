#!/bin/bash
if [ -z $APIKEY ]; then
    echo "Please set your APIKEY environment variable."
    exit 1
fi
for i in {1..55}; do
    if [ -d problems/solutions-$i ]; then
        if [ -n "$(ls problems/solutions-$i)" ]; then
            BEST=$(cd problems/solutions-$i/; ls | grep '^[0-9]*[.]json$' | sort -n | tail -n 1)
            if [ ! -f problems/solutions-$i/$BEST.submitted ]; then
                if
                    echo "Submitting solutions-$i/$BEST"
                    jq '{"problem_id": '$i', "contents": .|tojson}' problems/solutions-$i/$BEST \
                    | curl -L -sS -X POST \
                        -H "Authorization: Bearer $APIKEY" \
                        -H "Content-Type: application/json" \
                        -H "Accept: application/json" \
                        --data @- \
                        https://api.icfpcontest.com/submission \
                    | tee /dev/stderr \
                    | grep -q '"........................"'
                then
                    echo
                    touch problems/solutions-$i/$BEST.submitted
                    git add problems/solutions-$i/$BEST
                    git add problems/solutions-$i/$BEST.submitted
                else
                    echo
                fi
            fi
        fi
    fi
done
