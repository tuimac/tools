#!/usr/bin/env python

from multiprocessing import Process, cpu_count
from os import statvfs, urandom, mkdir, path, listdir, remove
import cPickle
from random import choice

def calcFSpace(stat):
    return stat.f_bfree * stat.f_frsize

def writeObject(filepath):
    # Unit is byte.
    data_size = 104857600
    with open(filepath, 'wb') as f:
        cPickle.dump(urandom(data_size), f)

def manageWrite(basename, rootDir, stat):
    fileindex = 1
    dir = rootDir + basename + "dir/"
    if path.exists(dir) is False: mkdir(dir)

    while True:
        free_space = calcFSpace(stat)
        if free_space < 1000: break
        filepath = dir + basename + str(fileindex)
        writeObject(filepath)
        fileindex += 1
    print "Process has been finished."

def createFiles(filename, rootDir, stat):
    cores = cpu_count()
    process_list = []
    for core in range(cores):
        basename = filename + str(core) + "-"
        p = Process(target=manageWrite, args=(basename, rootDir, stat))
        p.start()
        process_list.append(p)
    [p.join() for p in process_list]

def removeFiles(rootDir, stat, targetSize):
    dir = rootDir
    flag = True
    for dirname in listdir(rootDir):
        for name in listdir(dir):
            filename = dir + name
            if path.isfile(filename):
                print filename
                remove(filename)
            print calcFSpace(stat)
            if calcFSpace(stat) > targetSize:
                break
                flag = False
            if flag is False: break
        dir = rootDir + dirname + "/"

def main():
    rootDir = "/data/"
    filename = "test2-"
    stat = statvfs(rootDir)
    # This variable is amount of size of modified files you want
    targetSize = 914828034048
    removeFiles(rootDir, stat, targetSize)
    #createFiles(filename, rootDir, stat)

if __name__ == '__main__':
    main()
