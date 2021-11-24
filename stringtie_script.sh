#!/bin/bash
#annotation = location of annotation file
annotation=/home/chaos/draic_data_analysis/annotation_file/gencode.v38.annotation.gtf
#dir = output location of ballgown table files
dir=/home/chaos/draic_data_analysis/draic_data_fastq_files


for i in *rmPCRdup.bam
do
  	date
        name=$(echo $i | awk -F"_" '{print $i}')
        echo $name
        echo "stringtie $i -G ${annotation} -o $name.annotation.gtf -p 40 -b ${dir} -A $name.gene_abund.out"
        #options for stringtie: -G is for annotation file, -o is for output gtf file, -p is or threads, -b is for location of ballown table files
        #options for stringtie: -A is for output of gene abundance file
        stringtie $i -G ${annotation} -o $name.annotation.gtf -p 40 -b ${dir} -A $name.gene_abund.out
done

