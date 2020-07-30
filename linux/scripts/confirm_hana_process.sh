#!/bin/bash

function start(){
    local index=0
    local flag=true
    local tmpfile='.result_'${RANDOM}_${RANDOM}'.txt'

    while $flag; do
        cp /dev/null $tmpfile
        /usr/sap/hostctrl/exe/sapcontrol -nr 00 -function GetProcessList | while read line; do
            echo $line >> $tmpfile
        done
        sleep 1
        while read line; do
            (( index++ ))
            if [ $index -ge 6 ]; then
                echo $line | grep YELLOW
                if [ $? -eq 0 ]; then
                    flag=true
                    break
                else
                    flag=false
                fi
            fi
        done < $tmpfile
    done
    rm $tmpfile
}

function stop(){
    local index=0
    local flag=true
    local tmpfile='.result_'${RANDOM}_${RANDOM}'.txt'

    while $flag; do
        cp /dev/null $tmpfile
        /usr/sap/hostctrl/exe/sapcontrol -nr 00 -function GetProcessList | while read line; do
            echo $line >> $tmpfile
        done
        sleep 1
        while read line; do
            (( index++ ))
            if [ $index -ge 6 ]; then
                echo $line | grep GRAY
                if [ $? -eq 1 ]; then
                    flag=true
                    break
                else
                    flag=false
                fi
            fi
        done < $tmpfile
    done
    rm $tmpfile
}

function main(){
    if [ $1 == 'start' ]; then
        /usr/sap/hostctrl/exe/sapcontrol -nr 00 -function Start
        start
    elif [ $1 == 'stop' ]; then
        /usr/sap/hostctrl/exe/sapcontrol -nr 00 -function Stop
        stop
    else
        echo 'Argument is wrong.'
        exit 1
    fi
}

main $1
