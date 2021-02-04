# sv-nf
 Nextflow workflow for structural variants with graph data using [vg](https://github.com/vgteam/vg).

## Rationale

## Implementation

## Requirements

## Usage
The typical command for running the pipeline is as follows:
        nextflow run main.nf [Options]

        Inputs Options:
        Construct Graph from reference:
        --reference             Path expression to input FASTA reference.
                                Input type: path (default: )
        --vcf                   Path expression to input VCF. Optional input.
                                Input type: string (default: )
        --vcf_index             Path expression to input VCF index. Required if --vcf.
                                Input type: string (default: )
        --max_nodes             Limit the maximum allowable node sequence size.
                                Nodes greater than this threshold will be divided.
                                Input type: string or int (default: 32)
        --graphviz              Graphviz mode. Options: 'dot', 'neato', 'fdp', 'sfdp',
                                'twopi' or 'circo'.
                                Input type: string (default: neato)

        Use prebuilt Graph:
        --graph                 Path expression to input vg graph reference.
                                Input type: path (default https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19240/hgsvc/hs38d1/HGSVC_hs38d1.vg)

        Map sequences to Graph:
        --gam                   Path to realign GAM input.
                                Input type: path (default: test/1mb1kgp/z.sim)
        --sequence              Align a string to the graph in graph.vg using 
                                partial order alignment.
                                Input type: string (default: )
        --fastq                 Path to fastq file, possibly compressed. Two files are 
                                allowed, one for each mate.
                                Input type: path (default: )
        --fasta                 Path to FASTA file that may have multiple lines per 
                                reference sequence.
                                Input type: path (default: )
        --hts                   Path to reads from htslib-compatible FILE (BAM/CRAM/SAM).
                                Input type: path (default: )

## Basic run command example
    nextflow run main.nf

## Publicly available Graph Reference Genomes
### Human
- 1000 Genomes: [https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19239/1kg/hs37d5/1kg_hs37d5.vg](https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19239/1kg/hs37d5/1kg_hs37d5.vg)
- Human Genome Structural Variant Consortium: [https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19240/hgsvc/hs38d1/HGSVC_hs38d1.vg](https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19240/hgsvc/hs38d1/HGSVC_hs38d1.vg)