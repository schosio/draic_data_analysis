#!/bin/bash
#annotation = location of annotation file
annotation=/home/chaos/draic_data_analysis/annotation_file/gencode.v38.annotation.gtf
#out_file = name of merged tf file
out_file=driac_data_merge_annotation.gtf

for i in *annotation.gtf
do
  	stringtie --merge -G $annotation -m 200 -o $out_file $i
done


