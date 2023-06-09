#!/usr/bin/env python3

import sys
import re

from statistics import mean, median, stdev
from argparse import ArgumentParser


def argparser():
    ap = ArgumentParser()
    ap.add_argument('--include-first', action='store_true')
    ap.add_argument('log', nargs='+')
    return ap


RE = re.compile(r' TFLOPs: (\S+) .*? tokens-per-second-per-gpu: (\S+)')


def main(argv):
    args = argparser().parse_args(argv[1:])

    flops, tokens = [], []
    for fn in args.log:
        with open(fn) as f:
            for l in f:
                m = RE.search(l)
                if m:
                    f, t = m.groups()
                    flops.append(float(f))
                    tokens.append(float(t))
    if not flops:
        print('no throughput lines found')
        return

    if not args.include_first:
        tokens = tokens[1:]
        flops = flops[1:]

    if len(tokens) < 2:
        print('not enough throughput lines found')
        return

    def print_stats(label, d):
        print(
            label,
            f'mean: {mean(d):.1f}',
            f'stdev: {stdev(d):.1f}',
            f'median: {median(d):.1f}',
            f'({len(d)} values)'
        )

    print_stats('tokens/sec/gpu:', tokens)
    print_stats('TFLOPs     :', flops)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
