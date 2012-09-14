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

git $GIT_OPTS log --pretty=format:'<commit>%n<field name="hash">%h</field>%n<field name="author">%an</field>%n<field name="date">%ai</field>%n<field name="subject_body">%s%n%b<field>%n</commit>'
