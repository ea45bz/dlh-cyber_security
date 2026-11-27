#!/bin/bash
# 3-linux_parse.sh – parse auth.log, audit.log and syslog into a unified JSON format

set -euo pipefail
IFS=$'\n\t'

ROOT="/home/admin/lab3/evidence_pack_primary"
AUTH_LOG="$ROOT/linux/auth.log"
AUDIT_LOG="$ROOT/linux/audit.log"
SYSLOG="$ROOT/linux/syslog"
OUT_FILE="linux_events.json"

awk '
{
    orig=$0                                     # keep the original line
    # --------------- header (RFC3164) -----------------------
    if (!match(orig, /^(\w{3}\s+[0-9]{1,2}\s+[0-9:]+)\s+(\S+)\s+([^\[:\s]+)(\[([0-9]+)\])?:?(.*)$/,
        h)) next                               # skip non‑matching lines
    ts=h[1]; host=h[2]; prg=h[3]; pid=(h[5]==""?"":h[5]); msg=h[6]

    # --------------- key/value pairs inside the message -------
    delete kv;                                    # reuse array each record
    while (match(msg, /([A-Za-z0-9_-]+)=("[^"]+"|[^ ]+)/, m)) {
        k=m[1]; v=m[2]
        gsub(/^"|"$/, "", v)                     # strip surrounding quotes
        kv[k]=v
        msg=substr(msg,RSTART+RLENGTH)
    }

    # --------------- extract user ---------------------------------
    usr=""
    if ("user" in kv)            usr=kv["user"]
    else if (match(msg, /user[:=]([A-Za-z0-9_.]+)/, u)) usr=u[1]

    # --------------- build JSON ----------------------------------
    printf("{\"timestamp_raw\":\"%s\",\"hostname\":\"%s\",\"program\":\"%s\",",
           ts, host, prg)

    if (pid=="")   printf("\"pid\":null,"); else printf("\"pid\":%s,", pid)
    if (usr!="")   printf("\"user\":\"%s\",", usr); else printf("\"user\":null,")

    # escape raw_message
    gsub(/"/,"\\\"", orig)
    printf "\"raw_message\":\"%s\",\"parsed_fields\":{", orig

    first=1
    for (k in kv) {
        if (!first) printf ","
        first=0
        v=kv[k]; gsub(/"/,"\\\"",v)
        printf "\"%s\":\"%s\"", k, v
    }
    printf "},\"source_origin\":\"evidence_pack\"}\n"
}
' "$AUTH_LOG"  > "$OUT_FILE.tmp"


awk '
{
    orig=$0                                     # keep the original line
    # --------------- header (RFC3164) -----------------------
    if (!match(orig, /^(\w{3}\s+[0-9]{1,2}\s+[0-9:]+)\s+(\S+)\s+([^\[:\s]+)(\[([0-9]+)\])?:?(.*)$/,
        h)) next                               # skip non‑matching lines
    ts=h[1]; host=h[2]; prg=h[3]; pid=(h[5]==""?"":h[5]); msg=h[6]

    # --------------- key/value pairs inside the message -------
    delete kv;                                    # reuse array each record
    while (match(msg, /([A-Za-z0-9_-]+)=("[^"]+"|[^ ]+)/, m)) {
        k=m[1]; v=m[2]
        gsub(/^"|"$/, "", v)                     # strip surrounding quotes
        kv[k]=v
        msg=substr(msg,RSTART+RLENGTH)
    }

    # --------------- extract user ---------------------------------
    usr=""
    if ("user" in kv)            usr=kv["user"]
    else if (match(msg, /user[:=]([A-Za-z0-9_.]+)/, u)) usr=u[1]

    # --------------- build JSON ----------------------------------
    printf("{\"timestamp_raw\":\"%s\",\"hostname\":\"%s\",\"program\":\"%s\",",
           ts, host, prg)

    if (pid=="")   printf("\"pid\":null,"); else printf("\"pid\":%s,", pid)
    if (usr!="")   printf("\"user\":\"%s\",", usr); else printf("\"user\":null,")

    # escape raw_message
    gsub(/"/,"\\\"", orig)
    printf "\"raw_message\":\"%s\",\"parsed_fields\":{", orig

    first=1
    for (k in kv) {
        if (!first) printf ","
        first=0
        v=kv[k]; gsub(/"/,"\\\"",v)
        printf "\"%s\":\"%s\"", k, v
    }
    printf "},\"source_origin\":\"evidence_pack\"}\n"
}
' "$SYSLOG" >> "$OUT_FILE.tmp"

# ------------------------------------------------------------
awk '
{
    orig=$0                                         # keep the original line
    # audit lines look like:
    # type=XYZ msg=audit(123456.789:10): pid=... uid=...
    if (!match(orig, /^type=([^[:space:]]+)\s+msg=audit\(([0-9]+\.[0-9]+:[0-9]+)\):(.*)$/, h)) next
    audit_type=h[1]
    ts_raw = h[2]                                   # epoch.timestamp
    msg   = h[3]

    # split the remaining part into key=value pairs
    delete kv
    while (match(msg, /([A-Za-z0-9_]+)=("[^"]+"|[^ ]+)/, m)) {
        k=m[1]; v=m[2]
        gsub(/^"|"$/, "", v)                      # strip quotes if any
        kv[k]=v
        msg=substr(msg,RSTART+RLENGTH)
    }

    # hostname: first field that looks like a host name in the key/value list
    hostname=""
    for (k in kv) {
        if (match(k, /^hostname$/i)) { hostname=kv[k]; break }
    }

    pid="null"
    if ("pid" in kv && kv["pid"] ~ /^[0-9]+$/) pid=kv["pid"]

    user="null"
    # use acct or uid as a crude user indicator
    if ("acct" in kv)   user=kv["acct"]
    else if ("uid" in kv)  { if (kv["uid"]=="0") user="root"; else user=kv["uid"] }

    # escaped raw message for JSON field
    gsub(/"/,"\\\"", orig)

    # build JSON object
    printf("{\"timestamp_raw\":\"%s\",\"hostname\":\"%s\",\"audit_type\":\"%s\",",
           ts_raw, hostname, audit_type)
    printf("\"pid\":%s,", pid)
    if (user=="null") printf "\"user\":null,"; else printf "\"user\":\"%s\"," , user

    printf "\"raw_message\":\"%s\",\"parsed_fields\":{", orig

    first=1
    for (k in kv) {
        if (!first) printf ","
        first=0
        v=kv[k]; gsub(/"/,"\\\"",v)
        printf "\"%s\":\"%s\"", k, v
    }
    printf "},\"source_origin\":\"evidence_pack\"}\n"
}
'  "$AUDIT_LOG" >> "$OUT_FILE.tmp"

# student telemetry
STUDY="$ROOT/student_telemetry/linux_events.json"
if [[ -f $STUDY ]]; then
    echo "appending student telemetry ..."
    awk '
        {
            if ($0 ~ /source_origin:/) next
            # ensure source_origin field exists
            sub(/}$/,"\"source_origin\":\"student_telemetry\"}")
            print
        }
    ' "$STUDY" >> "$OUT_FILE.tmp"
fi

mv "$OUT_FILE.tmp" "$OUT_FILE"

# summary counts
auth_lines=$(wc -l <"$AUTH_LOG")
syslog_lines=$(wc -l <"$SYSLOG")
audit_lines=$(wc -l <"$AUDIT_LOG")
stud_lines=$(test -f "$STUDY" && wc -l <"$STUDY" || echo 0)

total_records=$(wc -l <"$OUT_FILE")

echo "auth.log      ... $auth_lines lines  -> ~${auth_lines} records"
echo "syslog        ... $syslog_lines lines  -> ~${syslog_lines} records"
echo "audit.log     ... $audit_lines lines  -> ~$(($audit_lines/2)) records (grouped)"
echo "appending student telemetry ... $stud_lines records"
echo "$OUT_FILE: written"
