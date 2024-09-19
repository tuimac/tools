#!/usr/bin/env python3

import os
import shutil
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))

def resolve_filename_conflict(dst_file):
    base, extension = os.path.splitext(dst_file)
    counter = 1
    while os.path.exists(dst_file):
        dst_file = f"{base}_{counter}{extension}"
        counter += 1
    return dst_file

def copy(src_dir, dst_dir, extension):
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith(extension):
                src_file = os.path.join(root, file)
                dst_file = os.path.join(dst_dir, file)
                
                if not os.path.exists(dst_dir):
                    os.makedirs(dst_dir)
                
                shutil.copy2(src_file, resolve_filename_conflict(dst_file))

if __name__ == '__main__':
    copy(SCRIPT_DIR, os.path.join(SCRIPT_DIR, 'all-pics'), '.jpg')
