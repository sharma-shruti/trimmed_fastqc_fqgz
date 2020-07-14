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
    publishDir 'results/fastqc', mode: saveBy
    container 'quay.io/biocontainers/fastqc:0.11.9--0'


    input:
    set genomeFileName, file(genomeReads) from ch_in_fastqc

    output:
    path("""${genomeName}_fastqc""") into ch_out_fastqc


    script:
    genomeName= genomeFileName.toString().split("\\_")[0]
    
    """
    mkdir ${genomeName}_fastqc
    fastqc -o ${genomeName}_fastqc ${genomeReads[0]}
    fastqc -o ${genomeName}_fastqc ${genomeReads[1]}
    """
}

// TODO add multiqc command to concatenate everything
