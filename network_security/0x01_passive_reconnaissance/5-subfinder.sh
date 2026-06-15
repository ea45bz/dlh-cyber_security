#!/bin/bash
subfinder -silent -o $1.tmp -oI -active -d $1 |awk -F, '{print $1}'
cat $1.tmp |awk -F, -v OFS=',' '{print $1,$2}' >$1.txt
