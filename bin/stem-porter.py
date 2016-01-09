#!/usr/bin/env python
# coding: utf-8

import sys
from nltk.stem import porter

PS = porter.PorterStemmer()
stem_word = lambda word: PS.stem(word)

if __name__ == '__main__':
    for line in sys.stdin:
        word = line.strip()
        print(stem_word(word))
