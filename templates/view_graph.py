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
__template__ = "view_construct-nf"

if __file__.endswith(".command.sh"):
    GRAPH = "$graph".split(' ')
    print("Running {} with parameters:".format(
        os.path.basename(__file__)))
    print("GRAPH: {}".format(GRAPH))

def main(graph):
    # save graph as DOT file
    cli_view = ["vg",
                "view",
                "-dp"]
    
    cli_view += graph
    
    p_view = subprocess.Popen(cli_view, stdout=PIPE, stderr=PIPE, shell=False)
    stdout_view, stderr_view = p_view.communicate()

    # Attempt to decode STDERR output from bytes. If unsuccessful, coerce to
    # string
    try:
        stderr_view = stderr_view.decode("utf8")
    except (UnicodeDecodeError, AttributeError):
        stderr_view = str(stderr_view)

    print("Finished vg view subprocess with STDOUT:\\n"
          "======================================\\n{}".format(stdout_view))
    print("Fished vg view subprocesswith STDERR:\\n"
          "======================================\\n{}".format(stderr_view))
    print("Finished vg view with return code: {}".format(p_view.returncode))

    # save vg file
    with open("reference.dot", "wb") as vg_view_fh:
        vg_view_fh.write(stdout_view)


if __name__ == '__main__':
    main(GRAPH)