#!/bin/bash
sudo nmap -sn -PS23,80,443 $1
