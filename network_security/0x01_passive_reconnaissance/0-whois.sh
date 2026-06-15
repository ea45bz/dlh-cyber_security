#!/bin/bash
whois $1 |awk -F': ' -v OFS=',' '/^Tech|^Admin|^Registrant/ {print $1,$2}' >$1.csv 
