#!/bin/bash

# Build indexable commit logs for each repo URL passed as standard
# input.  This script assumes it is run from the riak-librarian root
# dir.
#
# Usage:
#    ./build-commit-logs.sh DIR
#
# Example:
#    ./build-commit-logs.sh < repos.txt commit-logs

RL_DIR=$PWD
DIR=$1

repo_name() {
    url=$1
    base=${url##*/}
    echo ${base%.git}
}

mkdir -p $DIR

while read url; do
    name=$(repo_name $url)
    repo_dir=/tmp/$name
    if [ ! -e $repo_dir ]; then
        echo "Cloning $name @ $url under dir $repo_dir"
        git clone $url $repo_dir
    else
        echo "Pull latest of $name @ $url under dir $repo_dir"
        pushd $repo_dir
        git pull
        popd
    fi
    logfile=$DIR/$name-commit-log.xml
    echo "Generating commit log $logfile"
    $RL_DIR/git-log-xml.sh -d $repo_dir > $logfile
    rm -rf $tmpdir
done

