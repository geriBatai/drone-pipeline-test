#!/usr/bin/env sh

key=${1}
val=${2}
[ "x${val}" == "x" ] && echo "${key} param not set" && exit 1
exit 0
