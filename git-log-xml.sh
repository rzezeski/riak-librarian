#!/bin/bash

# Format git log as XML
#
# Usage:
#   ./git-log-xml.sh > log.xml

git log --pretty=format:'<commit>%n<field name="hash">%h</field>%n<field name="author">%an</field>%n<field name="date">%ai</field>%n<field name="subject_body">%s%n%b<field>%n</commit>'
