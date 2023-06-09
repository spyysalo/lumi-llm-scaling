#!/usr/bin/env python3

import sys
import re

from collections import defaultdict
from statistics import mean, median, stdev
from argparse import ArgumentParser


COMM_OP_RE = re.compile(r'.*?comm op: (\S+) \| time \(ms\): (\S+) \| msg size: (\S+ \S+) .*')


def argparser():
    ap = ArgumentParser()
    ap.add_argument('log', nargs='+')
    return ap


def print_stats(label, d):
    try:
        s = f'{stdev(d):.1f}'
    except ValueError:
        s = 'N/A'
    print('\t'.join([
        label,
        'mean', f'{mean(d):.1f}',
        'stdev', s,
        'min', f'{min(d):.1f}',
        'max', f'{max(d):.1f}',
        'count', str(len(d)),
    ]))


def main(argv):
    args = argparser().parse_args(argv[1:])

    data = defaultdict(lambda: defaultdict(list))
    for fn in args.log:
        with open(fn) as f:
            for l in f:
                m = COMM_OP_RE.match(l)
                if m:                    
                    op, time, size = m.groups()
                    data[op][size].append(float(time))

    for op in data:
        print(op)
        for size in data[op]:
            print_stats(size, data[op][size])
        print()


if __name__ == '__main__':
    sys.exit(main(sys.argv))
