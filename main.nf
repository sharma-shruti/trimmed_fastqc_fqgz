#!/usr/bin/env nextflow

/*
################
params
################
*/

params.saveBy = 'copy'
params.trimmed= true


inputUntrimmedRawFilePattern = "./*_{R1,R2}.fastq.gz"

inputTrimmedRawFilePattern = "./*_{R1,R2}.p.fastq.gz"

inputRawFilePattern = params.trimmed ? inputTrimmedRawFilePattern : inputUntrimmedRawFilePattern

Channel.fromFilePairs(inputRawFilePattern)
        .into {  ch_in_fastqc }


/*
###############
fastqc
###############
*/



process fastqc {
    publishDir 'results/fastqc', mode: params.saveBy
    container 'quay.io/biocontainers/fastqc:0.11.9--0'


    input:
    set genomeFileName, file(genomeReads) from ch_in_fastqc

    output:
    path("""${genomeName}""") into ch_out_fastqc


    script:
    genomeName= genomeFileName.toString().split("\\_")[0]
    outdirName= genomeName
    
    """
    mkdir ${outdirName}
    fastqc -o ${outdirName} ${genomeReads[0]}
    fastqc -o ${outdirName} ${genomeReads[1]}
    """
}


