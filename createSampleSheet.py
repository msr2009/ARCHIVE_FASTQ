from argparse import ArgumentParser
import re

def createSampleSheet(runinfo):
    one_index_template = "[Data],,\nSample_ID,Sample_Name,index"
    two_index_template = "[Data],,,\nSample_ID,Sample_Name,index,index2"
        
    #search for index read lines in RunInfo.xml and extract number of cycles per index read
    f = open(runinfo, "r").read()
    index_reads = re.findall('NumCycles="(\d+)".*IsIndexedRead="Y"', f)
    #if index reads were found
    if index_reads:
        dummy_line = "foo,foo,"
        if len(index_reads) == 1:
            print one_index_template
            dummy_line += "".join(["A" for i in range(int(index_reads[0]))])
        elif len(index_reads) == 2:
            print two_index_template
            dummy_line += ",".join(["".join(["A" for i in range(int(index_reads[0]))]), \
		    		"".join(["A" for j in range(int(index_reads[1]))])])
        print dummy_line
        return
    #otherwise, no indexed reads in this run, so no need for a sample sheet
    else:
        return

if __name__ == "__main__":
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--runinfo', action = 'store', type = str, dest = 'runinfo', 
		    	help = "path to RunInfo.xml")

    args = parser.parse_args()

    createSampleSheet(args.runinfo)
