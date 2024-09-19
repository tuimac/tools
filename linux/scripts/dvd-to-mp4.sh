#!/bin/bash

TARGET_DIR=$(pwd)/dvd
OUT_FILE_DIR=$(pwd)/output

function convert() {
    local out_file_name=$1
    local video_ts_path=$2
    [[ ! -d $OUT_FILE_DIR ]] && { mkdir $OUT_FILE_DIR; }
    cat $video_ts_path/*.VOB > combined.vob
    ffmpeg -i combined.vob -c:v libx264 -c:a aac -crf 18 -preset slow -b:a 192k -movflags +faststart $OUT_FILE_DIR/$out_file_name
    rm combined.vob
}

function main() {
    local dir_list=$(find $TARGET_DIR -type d | grep VIDEO_TS)
    for dir_path in ${dir_list[@]}; do
        local file_name=$(basename $(dirname $dir_path)).mp4
        convert $file_name $dir_path
    done
}

main
