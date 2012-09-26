#!/bin/bash

# Build indexable posts from a mailman archive.
#
# Usage:
#     ./build-mailman-posts.sh URL DIR
#
# Example:
#     ./build-mailman-posts.sh http://lists.basho.com/pipermail/riak-users_lists.basho.com/ riak-users

URL=$1
shift
DIR=$1
shift

tmpdir=$(mktemp -d $DIR-XXXXX)
archives=$(curl $URL | sed -nE '/.*href="(.*\.txt\.gz)".*/ {s//\1/; p; }')

for name in $archives; do
    archive_url=$URL/$name
    file=$tmpdir/$name
    txt=${file%.gz}
    xml="${txt%.txt}.xml"

    wget -P $tmpdir $archive_url
    gunzip $file
    gawk -f mailman.awk $txt > $xml
    rm $txt
done

mv $tmpdir $DIR

