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

    OUT_CONSTRUCT.into{IN_GRAPH_VIEW; IN_INDEX_1; IN_INDEX_2; IN_GRAPH_MAP}

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
        file("*.png") into OUT_GRAPH_GRAPHVIZ

        script:
        "${mode} -Tpng -o graph.png ${dotfile}"

    }
} else {
    IN_INDEX = Channel.fromPath(params.graph).ifEmpty { exit 1, "[Pipeline error] No reference file provided with path:'${params.graph}'" }
    IN_INDEX.into{IN_INDEX_1; IN_INDEX_2 }
}

IN_KMER = Channel.value(params.kmer)


process index {

    publishDir "results/graph"

    input:
    file(graph) from IN_INDEX_1
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


def map_mode_expected = ['map', 'giraffe'] as Set

def parameter_diff_map = map_mode_expected - params.mapper
if (parameter_diff_map.size() > 1){
    println "[Pipeline warning] Parameter $params.mapper is not valid in the pipeline! Running with default 'vg'\n"
    mapper_mode = Channel.value('map')
} else {
    mapper_mode = Channel.value(params.mapper)
}

process map {

    publishDir "results/mapping"

    input:
    file xg from XG_FILE_1
    file gcsa from GCSA_FILE
    val mapper from mapper_mode

    output:
    file("*.gam") into OUT_MAP

    script:
    template "map.py"
}

OUT_MAP.into{OUT_MAP_1; OUT_MAP_VIEW}

process view_map {

    publishDir "results/mapping"

    input: 
    file vg_graph from IN_INDEX_2
    file gam from OUT_MAP_VIEW

    output:
    file("map.dot") into MAP_VIEW

    script:
    """
    vg view -d ${vg_graph} -A ${gam} > map.dot
    """
}

def graphviz_mode_expected = ['dot', 'neato', 'fdp', 'sfdp', 'twopi', 'circo'] as Set

def parameter_diff = graphviz_mode_expected - params.graphviz
if (parameter_diff.size() > 5){
    println "[Pipeline warning] Parameter $params.graphviz is not valid in the pipeline! Running with default 'neato'\n"
    IN_graphviz_map_mode = Channel.value('neato')
} else {
    IN_graphviz_map_mode = Channel.value(params.graphviz)
}

process graphviz_map {
    
    publishDir "results/plots", pattern: "*.png"

    // segmentation fault error in graphs to big
    errorStrategy { task.exitStatus == 139 ? 'ignore' : 'retry' }

    input:
    file(dotfile) from MAP_VIEW
    val mode from IN_graphviz_map_mode

    output:
    file("*.png") into OUT_MAP_GRAPHVIZ

    script:
    "${mode} -Tpng -o map_graph.png ${dotfile}"
}

if (params.augment) {

    OUT_MAP.into{ OUT_MAP_1; OUT_MAP_2}

    process pgconvert {

        input:
        file graph from XG_FILE_2

        output:
        file("graph.pg") into GRAPH_PG

        script:
        "vg convert ${graph} -p > graph.pg"

    }

    process augment {

        input:
        file graph from GRAPH_PG
        file gam from OUT_MAP_1

        output:
        file("aug.pg") into GRAPH_AUG

        script:
        "vg augment ${graph} ${gam} > aug.pg"
    }

    GRAPH_AUG.into{ GRAPH_AUG_1; GRAPH_AUG_2 }

    process pack_aug {

        publishDir "results/mapping"

        input:
        file pg from GRAPH_AUG_1
        file gam from OUT_MAP_2

        output:
        file("*.pack") into OUT_PACK

        script:
        "vg pack -x ${pg} -g ${gam} -o align.pack"
    }

    process call_aug {

        publishDir "results/mapping"

        input:
        file pack from OUT_PACK
        file pg from GRAPH_AUG_2

        output:
        file("*.vcf") into IN_VCF_PROCESS

        script:
        "vg call -k ${pack} ${pg} > output.vcf"

    }
} else {

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

        publishDir "results/vcf"

        input:
        file pack from OUT_PACK
        file graph from XG_FILE_3

        output:
        file("*.vcf") into IN_VCF_PROCESS

        script:
        "vg call -k ${pack} ${graph} > output.vcf"

    }
}

IN_VCF_PROCESS.into{ IN_VCF_PROCESS_1; IN_VCF_PROCESS_2}

process bcftools {

    publishDir "results/vcf"

    input:
    file vcf from N_VCF_PROCESS_1

    output:
    file("stats_vcf.txt") into OUT_BCF

    script:
    """
    bcftools stats ${vcf} > stats.vchk
    plot-vcfstats -p outdir file.vchk
    """

}

process report {

    publishDir "results/MultiQC"

    input:
    file graph_dot_plot from OUT_GRAPH_GRAPHVIZ
    file vcf_file from IN_VCF_PROCESS_2

    output:
    file ("multiqc_report.html")

    script:
    """
    cp ${workflow.projectDir}/bin/* .

    R -e "rmarkdown::render('report.Rmd', params = list(graph_dot_plot='${graph_dot_plot}', vcf_file='${vcf_file}'))"
    mkdir MultiQC && mv report.html multiqc_report.html

    """
}
