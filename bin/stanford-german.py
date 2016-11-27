#!/usr/bin/env python
# coding: utf-8

import os
import sys
os.environ['CLASSPATH'] = '/zen/tez/cts/lib/stanford-core-nlp/stanford-postagger-full-2015-12-09/stanford-postagger.jar'
os.environ['STANFORD_MODELS'] = '/zen/tez/cts/lib/stanford-core-nlp/stanford-postagger-full-2015-12-09/models'
from nltk.internals import find_jars_within_path
from nltk.tag.stanford import StanfordPOSTagger

st = StanfordPOSTagger('german-hgc.tagger')
stanford_dir = st._stanford_jar.rpartition('/')[0]
stanford_jars = find_jars_within_path(stanford_dir)
st._stanford_jar = ':'.join(stanford_jars)

if __name__ == '__main__':
    for line in sys.stdin:
        sentence = line.strip()
        if sentence == '000':
            sys.exit(0)
        tagged = st.tag(sentence.split())
        sys.stdout.write('|'.join(map(lambda l: '/'.join(l), tagged)) + "\n")
        sys.stdout.flush()
