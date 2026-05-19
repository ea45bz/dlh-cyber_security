#!/bin/bash
find $1 -user root -perm -4000 -exec ls -ldb {} \; 
