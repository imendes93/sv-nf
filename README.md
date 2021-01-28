# sv-nf
 Nextflow workflow for structural variants with graph data using [vg](https://github.com/vgteam/vg).

## Rationale

## Implementation

## Requirements

## Usage
The typical command for running the pipeline is as follows:
        nextflow run main.nf [Options]

        Inputs Options:
        --reference             Path expression to input FASTA reference.
                                Input type: path (default: test/tiny/tiny.fa)
        --vcf                   Path expression to input VCF. Optional input.
                                Input type: string (default: test/tiny/tiny.vcf.gz)
        --vcf_index             Path expression to input VCF index. Required if --vcf.
                                Input type: string (default: test/tiny/tiny.vcf.gz.tbi)

        --max_nodes             Limit the maximum allowable node sequence size.
                                Nodes greater than this threshold will be divided.
                                Input type: string or int (default: 32)

        --graphviz              Graphviz mode. Options: 'dot', 'neato', 'fdp', 'sfdp',
                                'twopi' or 'circo'.
                                Input type: string (default: neato)

## Basic run command example
    nextflow run main.nf