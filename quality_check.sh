#!/bin/bash
#[find] will find any file with extension .fastq
#the output of [find] will be piped to parallel
#parallel will use multi cores to run fastqc
#options for find : -name is to search based on name with name as an argument in "" 
#options for parallel : the -v option is for verbose, -I% option is for , --max-args is for maximum arguments parallel can take input simultaniously
#options for fastqc: --extract is for unziping the output file
find . -name "*.fastq" | parallel -v -I% --max-args 1 fastqc --extract

