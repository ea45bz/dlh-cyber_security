#!/bin/bash 
ps auxh |grep -v "0     0"|grep ^$1 
