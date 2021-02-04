#!/usr/bin/env python3

"""
Blablabla
"""

#imports
import os
import subprocess
from subprocess import PIPE

__version__ = "0.0.1"
__build__ = "04.02.2021"
__template__ = "map-nf"

if __file__.endswith(".command.sh"):
    XG = "$xg"
    GCSA = "$gcsa"
    SEQUENCE = "$params.sequence"
    FASTQ = "$params.fastq"
    GAM = "$params.gam"
    FASTA = "$params.fasta"
    HTS = "$params.hts"

    print("Running {} with parameters:".format(
        os.path.basename(__file__)))
    print("XG: {}".format(XG))
    print("GCSA: {}".format(GCSA))
    print("SEQUENCE: {}".format(SEQUENCE))
    print("FASTQ: {}".format(FASTQ))
    print("GAM: {}".format(GAM))
    print("FASTA: {}".format(FASTA))
    print("HTS: {}".format(HTS))


def main(xg, gcsa, sequence=None, fastq=None, gam=None, fasta=None, hts=None):
    """ Main executor of the vg construct template.
    Parameters
    ----------
    reference : list
        N* element list containing the reference files.
    vcf : list
        N* element list containing the reference files.
    max_nodes : int or str
        Number of nodes that will be in the graph.
    """

    # setting command line for vg construct
    cli = ["vg",
           "map",
           '-x',
           xg,
           '-g',
           gcsa]
    
    # sequence
    if sequence != '':
        cli += ["-s", sequence]
    if fastq != '':
        cli += ["-f"] + fastq.split(' ')
    if gam != '':
        cli += ["-G", gam]
    if fasta != '':
        cli += ["-F", fasta]
    if hts != '':
        cli += ["-b", hts]
    
    print("Running fastqc subprocess with command: {}".format(cli))

    p = subprocess.Popen(cli, stdout=PIPE, stderr=PIPE, shell=False)
    stdout, stderr = p.communicate()

    # Attempt to decode STDERR output from bytes. If unsuccessful, coerce to
    # string
    try:
        stderr = stderr.decode("utf8")
    except (UnicodeDecodeError, AttributeError):
        stderr = str(stderr)

    print("Finished vg construct subprocess with STDOUT:\\n"
          "======================================\\n{}".format(stdout))
    print("Fished vg construct subprocesswith STDERR:\\n"
          "======================================\\n{}".format(stderr))
    print("Finished vg construct with return code: {}".format(p.returncode))

    # save gam file
    with open("map.gam", "wb") as vg_fh:
        vg_fh.write(stdout)

if __name__ == '__main__':
    main(XG, GCSA, SEQUENCE, FASTQ, GAM, FASTA, HTS)
