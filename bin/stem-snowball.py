#!/usr/bin/env python
# coding: utf-8

import sys
from nltk.stem.snowball import SnowballStemmer

if __name__ == '__main__':
    stemmer = SnowballStemmer(sys.argv[1])
    for line in sys.stdin:
        word = line.strip()
        if word == '000':
            sys.exit(0)
        sys.stdout.write(stemmer.stem(word) + "\n")
        sys.stdout.flush()
