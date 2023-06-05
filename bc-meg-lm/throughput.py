#!/usr/bin/env python3

import sys
import re

from statistics import mean, median, stdev


RE = re.compile(r' TFLOPs: (\S+)')
#RE = re.compile(r' samples per second: (\S+) .*? TFLOPs: (\S+)')


def main(argv):
    samples, flops = [], []
    for fn in argv[1:]:
        with open(fn) as f:
            for l in f:
                m = RE.search(l)
                if m:
                    #s, t = m.groups()
                    t = m.group(1)
                    #samples.append(float(s))
                    flops.append(float(t))
    if not flops:
        print('no throughput lines found')
        return

    def print_stats(label, d):
        print(
            label,
            f'mean: {mean(d):.1f}',
            f'stdev: {stdev(d):.1f}',
            f'median: {median(d):.1f}',
            f'({len(d)} values)'
        )

    #print_stats('samples/sec:', samples)
    print_stats('TFLOPs     :', flops)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
