NEWDIR=$2
OLDDIR=$1
TARDIR=`basename $NEWDIR`
ARCHIVEDIR=${3:-nextseq}

#check first to make sure that the new folder exists:
if [ $(ls -A $NEWDIR/*.sfq | wc -l) -gt 0 ];
then
        echo FOUND OUTPUT FOLDER, CONTAINS COMPRESSED FILES... DELETING $OLDDIR
		cd $NEWDIR/.. #move to parent directory of folder containing compressed fastqs
		chmod -R a+rx $TARDIR
#		tar -cvf $TARDIR.tar $TARDIR
#		chmod a+rx $TARDIR.tar
		rsync -aHXxvc --remove-source-files -e "ssh -T -o Compression=no -x" --progress $TARDIR root@fields-backup.gs.washington.edu:/volume1/ARCHIVED_FASTQ/$ARCHIVEDIR
#		rm -rf $NEWDIR
#		rm -rf $OLDDIR
else
        echo NO OUTPUT FOLDER, SO WILL NOT DELETE $OLDDIR
        exit 1
fi
