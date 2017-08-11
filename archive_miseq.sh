#source modules so we can use them
. /etc/profile.d/sge.sh
. /etc/profile.d/modules.sh
module load modules{,-{init,gs/prod}}

#we need to know whether these are miseq or nextseq runs so we can put them in the
#correct archive folder
RUNFOLDER=$1
[[ $1 =~ miseq ]] && ARCHIVEFOLDER="miseq" || ARCHIVEFOLDER="nextseq"

TMPARCHIVE=/net/fields/vol1/instrument/ARCHIVE/

for x in $(find /net/fields/vol1/miseq/Output/* -maxdepth 0 -ctime +14 -regextype posix-extended -regex '.*[0-9]{6}_(NS|M)[0-9]{5,6}.*' -exec basename {} \; ); do
	ssh root@fields-backup.gs.washington.edu "test ! -e /volume1/ARCHIVED_FASTQ/miseq/${x}*";
	if [ $? -eq 0 ]; then
		echo ${x} "NEEDS ARCHIVING"
		qsub -V -S /bin/bash -l mfree=2G /net/fields/vol2/home/mattrich/bin/ARCHIVE_FASTQ/archive_fastq.sh ${x} $TMPARCHIVE miseq
	fi
done

