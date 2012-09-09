#!/bin/bash

# Turn off file globbing so mail text isn't mangled
set -f

num=1
first=0
dir=$(mktemp -d riak-ml-XXXX)

exec <$1
while read line
do
    if echo $line | grep -Eq 'From .* at .* [0-9]{4}'; then
        if [ $first -eq 1 ]; then
            num=$((num + 1))
        else
            # first msg
            first=1
            echo $line >> $dir/$num.txt
        fi
    else
        echo $line >> $dir/$num.txt
    fi
done

echo Files written to $dir
