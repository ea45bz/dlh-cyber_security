#!/bin/bash
echo "$1"|sha256sum |tr -d "  -">1_hash.txt
