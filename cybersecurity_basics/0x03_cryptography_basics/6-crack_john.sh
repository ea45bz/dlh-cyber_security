#!/bin/bash
john --format=raw-sha256 --wordlist=rockyou.txt $1
