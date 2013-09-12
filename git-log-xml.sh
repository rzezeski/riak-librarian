#!/bin/bash

# Format git log as XML
#
#> Usage:
#>   ./git-log-xml.sh [ -d GIT_DIR ] > log.txt

GIT_OPTS=""
DIR=$PWD

usage() {
    echo
    grep '^#>' $0 | tr -d '#>'
}

error() {
    msg=$1

    echo $msg
    usage
    exit 1
}

while test $# -gt 0
do
    case $1 in
        -d)
            shift
            GIT_OPTS="$GIT_OPTS --git-dir=$1/.git --work-tree=$1"
            DIR=$1
            ;;
        -*)
            error "Unrecognized option: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

REPO_NAME=$(basename $DIR)

# TODO: convert time to UTC, right now just pretending local is UTC
git $GIT_OPTS log --pretty=format:"<commit>%n<repo>$REPO_NAME</repo>%n<hash>%H</hash>%n<author>%an</author>%n<dt>%ct</dt>%n<subject><![CDATA[%s]]></subject>%n<body><![CDATA[%b]]></body>%n</commit>" \
    | gawk 'match($0, /(<dt>)(.*)(<.*dt>)/, x) { printf("%s%s%s\n", x[1], strftime("%Y-%m-%dT%H:%M:%SZ", x[2]), x[3]); next; } { print $0 }'
