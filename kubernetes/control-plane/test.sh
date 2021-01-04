#!/bin/bash

ALL=`kubectl get pods -A | wc -l`

for i in {0..100}; do
    PENDING=`kubectl get pods --all-namespaces --field-selector status.phase=Pending | wc -l`
    [[ $All -eq $PENDING ]] && { echo 'All OK'; break; }
    sleep 2
done
echo done
