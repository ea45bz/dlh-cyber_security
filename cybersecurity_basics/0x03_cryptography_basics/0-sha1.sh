#!/bin/bash
echo $1 |sha1sum -t -  | cut -f 1 -d " " >0_hash.txt
