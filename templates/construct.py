#!/usr/bin/env python3

"""
Blablabla
"""

#imports
import os
import subprocess
from subprocess import PIPE

__version__ = "0.0.1"
__build__ = "28.01.2021"
__template__ = "construct-nf"

if __file__.endswith(".command.sh"):
    REFERENCE = "$reference".split(' ')
    VCF = "$vcf".split(' ')
    MAX_NODES = "$max_nodes"
    print("Running {} with parameters:".format(
        os.path.basename(__file__)))
    print("REFERENCE: {}".format(REFERENCE))
    print("VCF: {}".format(VCF))
    print("MAX_NODES: {}".format(MAX_NODES))


def check(filename):
    """
    check if it's a skip file
    """
    with open(filename) as f:
        try:
            if 'skip' in f.read():
                return False
        except:
            return True
    return True


def main(reference, vcf, max_nodes):
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
           "construct"]
    
    # reference and vcf files (1 or more)
    for reference_file in reference:
        cli += ["-r", reference_file]
    # vcf file is optional
    for vcf_file in vcf:
        if check(vcf_file):
            cli += ["-v", vcf_file]

    # nodes 
    cli += ["-m", max_nodes]
    
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

    # save vg file
    with open("reference.vg", "wb") as vg_fh:
        vg_fh.write(stdout)

if __name__ == '__main__':
    main(REFERENCE, VCF, MAX_NODES)