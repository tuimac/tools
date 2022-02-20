#!/bin/bash

status=$(docker inspect --type=container --format {{.State.Status}} postgresql)
echo $status
