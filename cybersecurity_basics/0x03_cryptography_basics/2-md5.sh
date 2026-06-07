#!/bin/bash
echo "$1"|md5sum |tr -d "  -">2_hash.txt
