#!/bin/bash
python -c "import base64,sys; print(''.join([chr(b ^ 0x5F) for b in base64.b64decode(sys.argv[1][5:])]))" $1
