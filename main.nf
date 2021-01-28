#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf [Options]
    
    Inputs Options:
    --reference             Path expression to input FASTA reference.
                            Input type: path (default: $params.reference)
    --vcf                   Path expression to input VCF.
                            Input type: string (default: $params.sample_vcf)
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

if (!params.reference && !params.vcf){exit 1, "'reference' or 'vcf' parameter missing"}

// RAW INPUTS
IN_referece_raw = Channel.fromPath(params.reference).ifEmpty { exit 1, "No reference file provided with path:'${params.reference}'" }
IN_max_nodes = Channel.value(params.max_nodes)

if (params.vcf){
    IN_vcf_raw = Channel.fromPath(params.vcf).ifEmpty { exit 1, "No vcf file provided with path:'${params.vcf}'" }
    IN_vcf_index_raw = Channel.fromPath(params.vcf_index).ifEmpty { exit 1, "No vcf index file provided with path:'${params.vcf_index}'" }
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

process graphviz {
    
    publishDir "results/plots", pattern: "*.pdf"

    input:
    file(dotfile) from GRAPH_DOTFILE

    output:
    file("*.pdf")

    script:
    "neato -Tpdf -o graph.pdf ${dotfile}"

}
