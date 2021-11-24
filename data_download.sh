#!/bin/bash
#while loop for downloading multiple files
#SRR_Acc.txt file contains SRR identfiers of the respecive SRA files e.g. SRR5370445
#SRR_Acc is location of SRR.Acc.txt file
srr_Acc=/home/chaos/15_nov/SRR_Acc.txt
#out_dir=location of output directory
out_dir=/home/chaos/15_nov/samples
while read -r line; do
                # Reading each line
                        echo $line
                                fasterq-dump $line -O ${out_dir}
                        done < ${srr_Acc}

