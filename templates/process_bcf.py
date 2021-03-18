#!/usr/bin/env python3

"""
Blablabla
"""

#imports
import os
import csv

__version__ = "0.0.1"
__build__ = "18.03.2021"
__template__ = "process_bcf_stats-nf"

if __file__.endswith(".command.sh"):
    BCF_STATS = "$vcf_stats"
    print("Running {} with parameters:".format(
        os.path.basename(__file__)))
    print("BCF_STATS: {}".format(BCF_STATS))


def main(bcf_stats):

    summary = ""
    substitution_csv = []
    with open(bcf_stats) as fh:
        for line in fh:
            if "Summary numbers" in line:
                header = next(fh).strip().split('\t')
                line = next(fh)
                table = []
                while "#" not in line:
                    to_write = line.strip().split('\t')
                    summary += to_write[-2] + ': ' + to_write[-1] + '\\n'
                    table.append(line.strip().split('\t'))
                    line = next(fh)
            if "Substitution types" in line:
                line = next(fh)
                substitution_csv = [line.strip().split('\t')[1:]]
                line = next(fh)
                while "#" not in line:
                    substitution_csv.append(line.strip().split('\t')[1:])
                    line = next(fh)

    with open("summary.txt", "w") as fh:
        fh.write(summary)
    
    with open("substitutions.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerows(substitution_csv)


if __name__ == '__main__':
    main(BCF_STATS)
    #main("stats.vchk")
