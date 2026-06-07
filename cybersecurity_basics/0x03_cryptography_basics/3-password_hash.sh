#!/bin/bash
echo "`openssl rand 16`$1" |  openssl dgst -sha512
