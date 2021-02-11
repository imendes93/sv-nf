# sv-nf
Nextflow workflow for structural variants with graph data using [vg](https://github.com/vgteam/vg).

## Rationale
this workflow allows the build of a variation graph from a reference FASTA file and variants in a 
VCF file, map reads to the graph and genotype those variants. Implements the [vg](https://github.com/vgteam/vg) toolkit.

## Implementation
A variation graph can be constructed (`--reference`, `--vcf` and `--vcf_index`) or a prebuilt graph can be provided (`--graph`).
Two options are available to map sequences to the graph: **map** and **giraffe**. Map uses vg's default mapping algorythm. 
Giraffe is a faster mapping algorythm with accuracy similar to vg map. 
The graph provided can be augmented `--augment=true` so that variation from alignments can be embedded back into the graph.

## Requirements
This workflow requires at least 4 cpus and 8GB of memory.

## Usage
The typical command for running the pipeline is as follows:
    nextflow run main.nf [Options]
    
    Inputs Options:

    Construct Graph from reference:
    --reference             Path expression to input FASTA reference.
                            Input type: path (default: $params.reference)
    --vcf                   Path expression to input VCF. Optional input.
                            Input type: string (default: $params.vcf)
    --vcf_index             Path expression to input VCF index. Required if --vcf.
                            Input type: string (default: $params.vcf_index)
    --max_nodes             Limit the maximum allowable node sequence size.
                            Nodes greater than this threshold will be divided.
                            Input type: string or int (default: $params.max_nodes)
    --graphviz              Graphviz mode. Options: 'dot', 'neato', 'fdp', 'sfdp',
                            'twopi' or 'circo'.
                            Input type: string (default: $params.graphviz)
    
    Use prebuilt Graph:
    --graph                 Path expression to input vg graph reference.
                            Input type: path (default $params.graph)

    Map sequences to Graph:
    --mapper                Mapping mode. Options: 'map', 'giraffe'.
                            Input type: string (default: $params.mapper)
    Compatible with vg map and vg giraffe:
    --gam                   Path to realign GAM input.
                            Input type: path (default: $params.gam)
    --fastq                 Path to fastq file, possibly compressed. Two files are 
                            allowed, one for each mate.
    Compatible only with vg map:
    --sequence              Align a string to the graph in graph.vg using 
                            partial order alignment.
                            Input type: string (default: $params.sequence)
    --fasta                 Path to FASTA file that may have multiple lines per 
                            reference sequence.
                            Input type: path (default: $params.fasta)
    --hts                   Path to reads from htslib-compatible FILE (BAM/CRAM/SAM).
                            Input type: path (default: $params.hts)
    
    --kmer                  kmer size to index in the graph.
                            Input type: int (default: $params.kmer)
    
    --augment               Add variation from aligned reads into the graph.
                            Options: true, false. Input type: boolean
                            (default: $params.augment)

## Basic run command example
    nextflow run main.nf

## Run test
    nextflow run main.nf -profile test,<docker...>

## Publicly available Graph Reference Genomes
### Human
- 1000 Genomes: [https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19239/1kg/hs37d5/1kg_hs37d5.vg](https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19239/1kg/hs37d5/1kg_hs37d5.vg)
- Human Genome Structural Variant Consortium: [https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19240/hgsvc/hs38d1/HGSVC_hs38d1.vg](https://cgl.gi.ucsc.edu/data/giraffe/mapping/graphs/for-NA19240/hgsvc/hs38d1/HGSVC_hs38d1.vg)