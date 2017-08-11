#source modules so we can use them
. /etc/profile.d/sge.sh
. /etc/profile.d/modules.sh
module load modules{,-{init,gs/prod}}

#we need to know whether these are miseq or nextseq runs so we can put them in the
#correct archive folder
RUNFOLDER=$1
[[ $1 =~ miseq ]] && ARCHIVEFOLDER="miseq" || ARCHIVEFOLDER="nextseq"

TMPARCHIVE=/net/fields/vol1/instrument/ARCHIVE/
BIN=/net/fields/vol2/home/mattrich/bin/ARCHIVE_FASTQ/
OUTPUTFOLDER=/net/fields/vol2/fieldslab-inst/nextseq/Output/

for x in $(find /net/fields/vol2/fieldslab-inst/nextseq/Output/* -maxdepth 0 -ctime +14 -regextype posix-extended -regex '.*[0-9]{6}_(NS|M)[0-9]{5,6}.*' -exec basename {} \; ); do
	ssh root@fields-backup.gs.washington.edu "test ! -e /volume1/ARCHIVED_FASTQ/nextseq/${x}*";
	if [ $? -eq 0 ]; then
		echo ${x} "NEEDS ARCHIVING"
		qsub -V -S /bin/bash -l mfree=5G $BIN/archive_fastq.sh $OUTPUTFOLDER/${x} $TMPARCHIVE nextseq
	fi
done

