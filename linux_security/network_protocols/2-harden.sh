#!/bin/bash
sudo find "/tmp/test" -type d -perm /o=w -print -exec chmod o-w '{}' \;
