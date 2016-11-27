#!/usr/bin/env python2
# coding: utf-8

import sys
sys.path.insert(0, '/zen/tez/pattern-2.6/build/lib')
from pattern.de import parse

parse_sent = lambda sent: parse(sent, tokenize = True, tags = True, chunks = True, relations = True, lemmata = True)

#if __name__ == '__main__':
#    while True:
line = sys.stdin.readline()
sent = line.strip().decode('utf-8')
if sent == '000':
    sys.exit(0)
ps = parse_sent(sent).encode('utf-8') + "\n"
sys.stdout.write(ps)
