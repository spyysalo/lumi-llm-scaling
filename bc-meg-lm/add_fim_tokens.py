#!/usr/bin/env python3

import sys
import json


FIM_TOKENS = [
    '<fim_prefix>',
    '<fim_middle>',
    '<fim_suffix>',
    '<fim_pad>',
]


with open(sys.argv[1]) as f:
    vocab = json.load(f)

for t in FIM_TOKENS:
    if t not in vocab:
        vocab[t] = max(vocab.values())+1

print(json.dumps(vocab))
