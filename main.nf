#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
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
    --gam                   Path to realign GAM input.
                            Input type: path (default: $params.gam)
    --sequence              Align a string to the graph in graph.vg using 
                            partial order alignment.
                            Input type: string (default: $params.sequence)
    --fastq                 Path to fastq file, possibly compressed. Two files are 
                            allowed, one for each mate.
                            Input type: path (default: $params.fastq)
    --fasta                 Path to FASTA file that may have multiple lines per 
                            reference sequence.
                            Input type: path (default: $params.fasta)
    --hts                   Path to reads from htslib-compatible FILE (BAM/CRAM/SAM).
                            Input type: path (default: $params.hts)
    
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

if (params.reference){

    // RAW INPUTS
    IN_referece_raw = Channel.fromPath(params.reference).ifEmpty { exit 1, "[Pipeline error] No reference file provided with path:'${params.reference}'" }
    IN_max_nodes = Channel.value(params.max_nodes)

    if (params.vcf){
        IN_vcf_raw = Channel.fromPath(params.vcf).ifEmpty { exit 1, "[Pipeline error] No vcf file provided with path:'${params.vcf}'" }
        IN_vcf_index_raw = Channel.fromPath(params.vcf_index).ifEmpty { exit 1, "[Pipeline error] No vcf index file provided with path:'${params.vcf_index}'" }
    } else {
        IN_vcf_raw = Channel.from('skip')
        IN_vcf_index_raw = Channel.from('skip')
    }

    process construct {

        publishDir "results/graph", pattern: "*.vg" 

        input:
        file(reference) from IN_referece_raw.collect()
        file(vcf) from IN_vcf_raw.collect()
        file(vcf_index) from IN_vcf_index_raw.collect()
        val max_nodes from IN_max_nodes

        output:
        file("*.vg") into OUT_CONSTRUCT

        script:
        template "construct.py"
    }

    OUT_CONSTRUCT.into{IN_GRAPH_VIEW; IN_INDEX}

    process view_construct {
        
        publishDir "results/plots", pattern: "*.dot"
        
        input:
        file(graph) from IN_GRAPH_VIEW

        output:
        file("*.dot") into GRAPH_DOTFILE optional true

        script:
        template "view_graph.py"

    }

    // check graphviz parameters... in a hacky way
    def graphviz_mode_expected = ['dot', 'neato', 'fdp', 'sfdp', 'twopi', 'circo'] as Set

    def parameter_diff = graphviz_mode_expected - params.graphviz
    if (parameter_diff.size() > 5){
        println "[Pipeline warning] Parameter $params.graphviz is not valid in the pipeline! Running with default 'neato'\n"
        IN_graphviz_mode = Channel.value('neato')
    } else {
        IN_graphviz_mode = Channel.value(params.graphviz)
    }

    process graphviz {
        
        publishDir "results/plots", pattern: "*.pdf"

        // segmentation fault error in graphs to big
        errorStrategy { task.exitStatus == 139 ? 'ignore' : 'retry' }

        input:
        file(dotfile) from GRAPH_DOTFILE
        val mode from IN_graphviz_mode

        output:
        file("*.pdf")

        script:
        "${mode} -Tpdf -o graph.pdf ${dotfile}"

    }
} else {
    IN_INDEX = Channel.fromPath(params.graph).ifEmpty { exit 1, "[Pipeline error] No reference file provided with path:'${params.graph}'" }
}

IN_KMER = Channel.value(params.kmer)


process index {

    publishDir "results/graph"

    input:
    file(graph) from IN_INDEX
    val kmer from IN_KMER

    output:
    file("*.xg") into XG_FILE
    file("*.gcsa") into GCSA_FILE

    script:
    """
    vg index -x graph.xg ${graph}
    vg index -g graph.gcsa -k ${kmer} ${graph}
    """
}

XG_FILE.into{ XG_FILE_1; XG_FILE_2; XG_FILE_3}

process map {

    publishDir "results/mapping"

    input:
    file xg from XG_FILE_1
    file gcsa from GCSA_FILE

    output:
    file("*.gam") into OUT_MAP

    script:
    template "map.py"
}

process pack {

    publishDir "results/mapping"

    input:
    file xg from XG_FILE_2
    file gam from OUT_MAP

    output:
    file("*.pack") into OUT_PACK

    script:
    "vg pack -x ${xg} -g ${gam} -o align.pack"
}

process call {

    publishDir "results/mapping"

    input:
    file pack from OUT_PACK
    file graph from XG_FILE_3

    output:
    file("*.vcf")

    script:
    "vg call -k ${pack} ${graph} > output.vcf"

}