#!/bin/bash
hash_file=`sha256sum $1 |cut -d ' ' -f1`
if [ "$2" = "$hash_file" ]; then echo "$1: OK"; fi
