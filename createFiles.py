#!/usr/bin/env python

from multiprocessing import Process, cpu_count
from random import gauss
from os import statvfs, urandom, mkdir, path
import cPickle

def writeObject(filepath):
    # Unit is byte.
    data_size = 104857600
    f = open(filepath, 'wb')
    cPickle.dump(urandom(data_size), f)
    f.close()

def manageWrite(basename):
    dir = "/data/"
    fileindex = 1
    stat = statvfs(dir)
    dir = dir + basename + "dir/"
    if path.exists(dir): mkdir(dir)

    while True:
        free_space = stat.f_frsize * stat.f_blocks
        if free_space < 1000: break
        filepath = dir + basename + "-" + str(fileindex)
        writeObject(filepath)
        fileindex += 1
    print "Process has been finished."

def main():
    filename = "test-"
    cores = cpu_count()
    process_list = []
    for core in range(cores):
        basename = filename + str(core) + "-"
        p = Process(target=manageWrite, args=(basename,))
        p.start()
        process_list.append(p)
    [p.join() for p in process_list]

if __name__ == '__main__':
    main()
