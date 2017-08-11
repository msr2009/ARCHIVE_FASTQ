IN_FQ=$1

#compress fastq with slimfastq
module load slimfastq/latest
slimfastq -3 ${IN_FQ} ${IN_FQ%%.fastq}.sfq
rm ${IN_FQ%%.gz}
