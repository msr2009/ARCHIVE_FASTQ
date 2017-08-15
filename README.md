# ARCHIVE_FASTQ
A pipeline for compressing and archiving Illumina sequencing reads

Matt Rich, 2017

DEPENDENCIES

python2
slimfastq (https://github.com/Infinidat/slimfastq) -- used for fastq compression
bcl2fastq (from Illumina)
SGE cluster environment

NOTE: some of the variables in these scripts (like locations of runfolders and
archive folders) are hard-coded. You should change these if necessary.


SCRIPTS

1) archive_fastq.sh -- main script calling all others (bcl2fastq is run here). 

2) createSampleSheet.py -- script creating a dummy sample sheet to be used by
bcl2fastq to perform basecalling. Script determines number of reads and lengths.

3) archive_compressFQ.sh -- calls slimfastq to perform compression

4) archive_delete.sh -- moves compressed files to backup location using rsync. NB:
This script was initially designed to also delete the intermediate folders and
original runfolder, but currently this is commented out until we can come up with a
good way to confirm that everything progressed properly.

5) archive_nextseq.sh -- this script compares the archive directory with our nextseq
runfolder in order to determine which runs need to be archived. It then submits
cluster jobs (of archive_fastq.sh) for each of those runfolders. This script can be
run as a cronjob.


DELETING RUNFOLDERS

Since archive_delete.sh doesn't actually delete runfolders (and any intermediate
files), this must be done manually. The rsync command run in archive_delete.sh
removes the original files after transferring them to the archive directory, so if
the intermediate output folders (hard-coded to be found in the instrument/ folder)
do not contain compressed reads, then I think they should have been tranferred
properly. It is probably worthwhile to check the backup location
(fields-backup.gs.washington.edu) to confirm that the .sfq files are of appropriate
size (a high-output nextseq run, when compressed, is still >20GB, for example).
Given those checks are correct, the original runfolders can be deleted.


