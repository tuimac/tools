#!/bin/bash

status=$(docker inspect --type=container --format {{.State.Status}} postgresql 2>/dev/null)
test "$status" = "runninge"
