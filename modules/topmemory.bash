#! /bin/bash
# Processes that uses most memory on system

#!/bin/sh

echo "******************** top memory usage ********************"
printf "%-8s %-8s %-9s %s\n" "PID" " User " "Total" "Command"
printf "%-8s %-8s %-9s %s\n" "---" "------" "-----" "-------"

for PID in `ps -e | awk '$1 ~ /[0-9]+/ { print $1 }'`; do
    CMD=`ps -o comm -p $PID | tail -1`
    if [[ "$CMD" == "sort" ]]; then 
        continue
    fi
    USER=`ps -o euser -p $PID | tail -1`
    TOTAL=`pmap $PID 2> /dev/null | tail -1 | awk '{ print $2 }'`
    if [ -n "$TOTAL" ]; then
        printf "%-8s %-8s %-9s %s\n" "$PID" "$USER" "$TOTAL" "$CMD"
    fi
done | /usr/bin/sort -nr -k3 | head -n 10
