#!/bin/bash
find $1 \( -perm -2000 -or -perm -4000 \) -mtime 1
