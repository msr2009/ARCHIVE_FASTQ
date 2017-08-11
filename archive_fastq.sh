#$ -S /bin/bash
#$ -l mfree=5G  
##$ -pe serial 4
##$ -l h_rt=72:0:0

#first check if there are three arguments
if [[ $# -lt 3 ]]; then
	echo "usage: archive_fastq.sh RUNFOLDER ARCHIVEDIR SEQUENCER bin"
	echo "	RUNFOLDER : Illumina run folder (-R for bcl2fastq)"
	echo "	ARCHIVEDIR : Directory to temporarily store archived files (cannot be RUNFOLDER or its parent directory)"
	echo "	SEQUENCER : nextseq or miseq"
	echo "	bin : directory containing all scripts (default = ~/bin/)"
	exit 1
fi

ILLUMINADIR=$1 #Illumina Run Folder
ARCHIVEDIR=$2 #Directory containing archived output	
OUTDIR=`basename $1` #illumina output directory name (without path)
SEQUENCER=$3 #nextseq or miseq
BIN=${4:-~/bin/ARCHIVE_FASTQ/} #set default bin as ~/bin/

#can get nanosecond counts from date for random numbers
#date +%N

#load modules
module load gcc/latest bcl2fastq/2.17 python/2.7.3

#First, check if output directory exists,
#and if not, throw error and quit
if [ ! -d "$ARCHIVEDIR" ]; then
 	echo ERROR: output directory does not exist. Make it and try again.
	exit 1
elif [ -e "$ARCHIVEDIR/$OUTDIR/*.tar" ]; then
	echo Directory has already been extracted and compressed, exiting.
	exit 1
fi

#write a dummy sample sheet for bcl2fastq
echo CREATING SAMPLE SHEET
SAMPLESHEET=$ARCHIVEDIR/sample_sheet_`date +%N`.csv
python $BIN/createSampleSheet.py --runinfo $ILLUMINADIR/RunInfo.xml > $SAMPLESHEET

#extract fastqs with bcl2fastq
#JBCL=archive_bcl_`date +%N`
echo RUNNING BCL2FASTQ
bcl2fastq -o $ARCHIVEDIR/$OUTDIR/ -R $ILLUMINADIR \
	--sample-sheet $SAMPLESHEET --with-failed-reads --no-lane-splitting \
	--mask-short-adapter-reads 0 --minimum-trimmed-read-length 0 \
	--create-fastq-for-index-reads --no-bgzf-compression --fastq-compression-level 1 \
	-r 1 -d 1 -p 1 -w 1

#concatenate dummy index reads to Undetermined read files
#and delete the dummy index reads file
echo CONCATENATING SPLIT FASTQS
cd $ARCHIVEDIR/$OUTDIR/
for x in foo*.fastq.gz; do
	RNAME=$(echo ${x} | sed -e "s/^foo_S1//" -e "s/_001.fastq.gz$//")
	zcat ${x} Undetermined_S0${x##foo_S1} >> READS$RNAME.fastq
	rm ${x}
	rm Undetermined_S0${x##foo_S1}
	chmod a+rx *.fastq
done

#update LOG file 
#folder name, read lengths, number of reads

##$LOGFILE=/net/fields/vol2/fieldslab-inst/nextseq/Output/ARCHIVED_RUNS.txt
#echo `python archive_updatelog.py -R $ILLUMINADIR` \
#		`grep -c for ~/bin/archive_fastq.sh` | \
#		awk '{OFS="\t"}{print $1, $2, $3}' >> $LOGFILE

#compress all the extracted fastqs
echo COMPRESSING FASTQs
COMPLIST=""
for x in READS*; do
	JCOMP=archive_comp_`date +%N`
	qsub -V -S /bin/bash -N $JCOMP -l mfree=200M $BIN/archive_compressFQ.sh $ARCHIVEDIR/$OUTDIR/${x}
	COMPLIST+=$JCOMP','
done

#after compression, delete original file
echo DELETING UNCOMPRESSED RUN FOLDER
qsub -hold_jid ${COMPLIST%%,} -V -S /bin/bash $BIN/archive_delete.sh $ILLUMINADIR $ARCHIVEDIR/$OUTDIR $SEQUENCER
