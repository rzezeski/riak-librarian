#!/bin/bash

# Format git log as XML
#
#> Usage:
#>   ./git-log-xml.sh [ -d GIT_DIR ] > log.xml

GIT_OPTS=""

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
            GIT_OPTS="$GIT_OPTS --git-dir=$2/.git --work-tree=$2"
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

git $GIT_OPTS log --pretty=format:'<commit>%n<hash_s>%h</hash_s>%n<author_ws>%an</author_ws>%n<date_ig>%ai</date_ig>%n<subject_body_t><![CDATA[%s%n%b]]></subject_body_t>%n</commit>'
