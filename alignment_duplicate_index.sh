#!/bin/bash

#threads = processors that will be used in process
threads=40
#idx = location of reference genome index
idx=/home/chaos/draic_data_analysis/hisat_index/hg38
#splicefile = location of gtf annotation file
splicefile=/home/chaos/draic_data_analysis/annotation_file/gencode.v38.splice.txt

#loop for hisat2

for i in *.fastq
do
  	date
	name=$(echo $i | awk -F"_" '{print $i}')
        echo $name
        #display the command used
        echo  "hisat2 -p $threads -x $idx --known-splicesite-infile $splicefile $i | samtools view -bS - | samtools sort -n - -o $name.sorted.bam"
        #options for hisat: -p is for threads used, --known-splicesite-infile is for splice site file
        #options for samtools: view is for file conversion, -bS is for .bam as output and .sam as input
        #options for samtools: sort is for sorting, -n is sorting by name, -o is for output
        hisat2 -p $threads -x $idx --known-splicesite-infile $splicefile $i | samtools view -bS - | samtools sort -n - -o $name.sorted.bam
done

for j in *.sorted.bam
do
  	    date
	      name1=$(echo $j | awk -F"_" '{print $i}')
        echo $name1
        echo "samtools fixmate -m $j - | samtools sort - | samtools markdup -rs - $name1.rmPCRdup.bam"
        #options for samtools: fixmate is for fix mate information, markdup is for marking duplicates       
        samtools fixmate -m $j - | samtools sort - | samtools markdup -rs - $name1.rmPCRdup.bam
done

for u in *.rmPCRdup.bam
do
  	date
    #options for samtools: index is for indexing the bam file, -b is to generate .bai index
	  samtools index -b $u
  
done

