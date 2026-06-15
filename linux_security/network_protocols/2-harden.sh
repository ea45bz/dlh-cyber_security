#!/bin/bash
find / -type d -xdev -perm /o=w -print -exec chmod o-w '{}' \;
