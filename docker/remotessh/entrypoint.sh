#!/bin/bash

$LOG='/root/development.log'

while true; do
    cat /sys/class/net >> $LOG 2>&1
    sleep 10
done
