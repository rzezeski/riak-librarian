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
git $GIT_OPTS log --pretty=format:"<commit>%n<repo_s>$REPO_NAME</repo_s>%n<hash_s>%H</hash_s>%n<author_s>%an</author_s>%n<author_dt>%at</author_dt>%n<committer_dt>%ct</committer_dt>%n<subject_body_tsd><![CDATA[%s%n%b]]></subject_body_tsd>%n</commit>" \
    | gawk 'match($0, /(<.*_dt>)(.*)(<.*_dt>)/, x) { printf("%s%s%s\n", x[1], strftime("%Y-%m-%dT%H:%M:%SZ", x[2]), x[3]); next; } { print $0 }'
