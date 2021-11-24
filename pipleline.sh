#!/bin/bash

#STEP 1:   downloading the fastq files from sequence read archive (ncbi)
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
                        
                   
#STEP2 :   checking the quality of fastq files using fastqc


#[find] will find any file with extension .fastq
#the output of [find] will be piped to parallel
#parallel will use multi cores to run fastqc
#options for find : -name is to search based on name with name as an argument in "" 
#options for parallel : the -v option is for verbose, -I% option is for , --max-args is for maximum arguments parallel can take input simultaniously
#options for fastqc: --extract is for unziping the output file
find . -name "*.fastq" | parallel -v -I% --max-args 1 fastqc --extract


#STEP 3: alignment


#threads = processors that will be used in process
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

#STEP 4 : removing the PCR duplicates

for j in *.sorted.bam
do
  	    date
	      name1=$(echo $j | awk -F"_" '{print $i}')
        echo $name1
        echo "samtools fixmate -m $j - | samtools sort - | samtools markdup -rs - $name1.rmPCRdup.bam"
        #options for samtools: fixmate is for fix mate information, markdup is for marking duplicates       
        samtools fixmate -m $j - | samtools sort - | samtools markdup -rs - $name1.rmPCRdup.bam
done
#STEP 5 : indexing the final .bam file


for u in *.rmPCRdup.bam
do
  	date
    #options for samtools: index is for indexing the bam file, -b is to generate .bai index
	  samtools index -b $u
  
done





#STEP 6 : Building transcripts from the reads using stringtie



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




#STEP 7 : merging the GTF files  using stringtie


#annotation = location of annotation file
annotation=/home/chaos/draic_data_analysis/annotation_file/gencode.v38.annotation.gtf
#out_file = name of merged tf file
out_file=driac_data_merge_annotation.gtf

for i in *annotation.gtf
do
  	stringtie --merge -G $annotation -m 200 -o $out_file $i
done 

#STEP 8 comparing the information in merged gtf from stringtie and annotation file

#merge_gtf = location of merged gtf file created in STEP 7
merge_gtf=/home/chaos/draic_data_analysis/draic_data_fastq_files/driac_data_merge_annotation.gtf

gffcompare -G -r $annotation $merge_gtf 


