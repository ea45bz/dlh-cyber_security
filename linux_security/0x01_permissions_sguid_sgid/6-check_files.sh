#!/bin/bash
find $1 -type f \( -perm -2000 -or -perm -4000 \) -mtime -1 -exec ls -ldb {} \; 2>/dev/null 
