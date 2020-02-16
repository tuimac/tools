#!/usr/bin/env python

from random import choice
from string import ascii_lowercase, digits

if __name__ == '__main__':
    size = 1000000
    lis=list(ascii_lowercase + digits)
    print ''.join(choice(lis) for _ in xrange(size))
