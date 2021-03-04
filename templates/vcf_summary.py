import io
import os
import json 
import fnmatch
import pandas as pd
import numpy as np
import matplotlib
from collections import defaultdict, Counter
import seaborn as sns
import matplotlib.pyplot as plt

__version__ = "0.0.1"
__build__ = "25.02.2021"
__template__ = "process_vcf-nf"

if __file__.endswith(".command.sh"):
    VCF = "$vcf"
    print("Running {} with parameters:".format(
        os.path.basename(__file__)))
    print("VCF: {}".format(VCF))

def main(vcf_file):
    """
    """
    



if __name__ == '__main__':
    #main(VCF)
    main("input_test.vcf")