#!/usr/bin/env python
# coding: utf-8

import sys
from nltk.stem import porter

PS = porter.PorterStemmer()
stem_word = lambda word: PS.stem(word)

if __name__ == '__main__':
    for line in sys.stdin:
        word = line.strip()
        if word == '000':
            sys.exit(0)
        sys.stdout.write(stem_word(word) + "\n")
        sys.stdout.flush()
