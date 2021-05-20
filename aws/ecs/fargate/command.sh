#!/bin/bash

aws ecs execute-command \
    --cluster test \
    --task xxxxxxxxxxxxxxxxxxxxxxx \
    --container httptracker \
    --interactive \
    --command "ls /"
