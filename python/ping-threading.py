#!/usr/bin/env python3

import subprocess
from queue import Queue
from threading import Thread


def command(cmd, queue):
    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            queue.put(output.strip())

def output(queue):
    while True:
        print('hello')
        print(queue.get())

if __name__ == '__main__':
    cmd = 'ping 8.8.8.8'
    queue = Queue()
    thread = Thread(target=output, args=(queue,))
    thread.start()
    command(cmd, queue)
    thread.join()
