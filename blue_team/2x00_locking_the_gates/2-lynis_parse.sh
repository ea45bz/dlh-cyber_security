#!/bin/bash
#
export PYTORCH_ENABLE_MPS_FALLBACK=1

python3 -c '
import sys, json
findings=[]
report=sys.argv[1]
with open(report, "r") as file:
  for line in file.readlines():
    try:
      key,content=line.split("=")
      if key in ("suggestion[]","warning[]","manual_check[]"):
        c=content.split("|")
        findings.append({ "severity": key[:-2],
          "test_id": c[0],
          "message": c[1]})
      elif key == "hardening_index":
        hardening_index = int(content)
    except Exception:
      pass

output = { "hardening_index": hardening_index,
        "findings": findings }

print(json.dumps(output, indent=4))
' $1
