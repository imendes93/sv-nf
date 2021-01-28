#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf [Options]
    
    Inputs Options:
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
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

if (!params.reference){exit 1, "[Pipeline error] 'reference' parameter missing"}

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

    publishDir "results/construct", pattern: "*.vg" 

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

process view_construct {
    
    publishDir "results/plots", pattern: "*.dot"
    
    input:
    file(graph) from OUT_CONSTRUCT

    output:
    file("*.dot") into GRAPH_DOTFILE

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

    input:
    file(dotfile) from GRAPH_DOTFILE
    val mode from IN_graphviz_mode

    output:
    file("*.pdf")

    script:
    "${mode} -Tpdf -o graph.pdf ${dotfile}"

}
