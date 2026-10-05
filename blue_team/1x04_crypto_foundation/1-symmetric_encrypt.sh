#!/bin/bash
if [ "$3" = "cbc" ]; then
  openssl enc -aes-256-cbc -k 123  -in $1 -out $2
elif [ "$3" = "gcm" ]; then
  openssl enc -aes-256-gcm -k 123  -in $1 -out $2
fi
