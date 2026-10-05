#!/bin/bash
#

HASH=$(md5sum  $1 |awk '{print $1}')
if [ "$HASH" = "$2" ]; then
    echo "INTEGRITY OK"
    exit 0
fi
echo "INTEGRITY FAILED - expected $HASH got $2"
exit 1
