#!/usr/bin/env nextflow

/*
################
params
################
*/

params.saveBy = 'copy'
params.trimmed= true
params.multiQC= false
params.resultsDir= 'results/fastqc'


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


if(!params.multiQC) {
process fastqc {
    publishDir params.resultsDir, mode: params.saveBy
    container 'quay.io/biocontainers/fastqc:0.11.9--0'


    input:
    set genomeFileName, file(genomeReads) from ch_in_fastqc

    output:
    tuple file('*.html'), file('*.zip') into ch_out_fastqc


    script:
    genomeName= genomeFileName.toString().split("\\_")[0]
    outdirName= genomeName
    
    """
    fastqc ${genomeReads[0]}
    fastqc ${genomeReads[1]}
    """
  }

}


if(params.multiQC) {
              
Channel.fromPath("""${params.resultsDir}""")
        .into {  ch_in_multiqc }
        
     
process multiQC {
    publishDir "results/multiqc", mode: params.saveBy
    container 'quay.io/biocontainers/multiqc:1.9--pyh9f0ad1d_0'

    input: 
    path("""${params.resultsDir}""") from ch_in_multiqc
    
    
    output:
    tuple path("""multiqc_data"""), 
          path("""multiqc_report.html""") into ch_out_multiqc


    
    script: 
    
    """
    multiqc ${params.resultsDir}
    """

}



}
