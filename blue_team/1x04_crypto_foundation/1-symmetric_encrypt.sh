#!/bin/bash
openssl enc -aes-256-$3 -k 123  -in $1 -out $2
