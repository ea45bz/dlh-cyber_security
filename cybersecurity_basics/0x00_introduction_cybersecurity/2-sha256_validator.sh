#!/bin/bash
#hash_file=`sha256sum $1 |cut -d ' ' -f1`
if [ "$(sha256sum $1 |cut -d ' ' -f1)" = "$2" ]; then echo "$1: OK"; fi
