#!/bin/bash

#now that we have done the high ld zones prunning me will continue to do a General QC for an Association 
#study

### Next lines specify that if no arguments for QC are given, then they'll be set
#to a default value
if [ -z "$geno" ];
then
    geno=0.01
    echo "parameter 'geno' or 'g' was not imputed, assigning it to ${geno}"
    
else
    echo "geno set to: ${geno}"
fi 
####
if [ -z "$mind" ];
then
    mind=0.01
    echo "parameter 'mind' or 'm' was not imputed, assigning it to ${mind}"
    
else
    echo "mind set to: ${mind}"
fi 
####
if [ -z "$maf" ];
then
    maf=0.01
    echo "parameter 'maf' or 'a' was not imputed, assigning it to ${maf}"
    
else
    echo "maf set to: ${maf}"
fi 
if [ -z "$hwe" ];
then
    hwe=0.01
    echo "parameter 'hwe' or 'h' was not imputed, assigning it to ${geno}"
    
else
    echo "hwe set to: ${hwe}"
fi 
###
if [ -z "$min" ];
then
    min=0.01
    echo "parameter 'min' or 'n' was not imputed, assigning it to ${min}"
    
else
    echo "min set to: ${min}"
fi 
if [ -z "$geno" ];
###
then
    rel_cutoff=0.01
    echo "parameter 'rel_cutoff' or 'r' was not imputed, assigning it to ${rel_cutoff}"
    
else
    echo "rel_cutoff set to: ${rel_cutoff}"
fi 
###

#next part it to chek whether the previous step (rhild removal) was made
#if not, then the input file for QC is the unprocesed data defined in the master script as 'input_file'
#and not the output from removing_complexes.sh
output_hild_prunning=${outdirectory}${todays_date}_QC/Removed_complexes/

if [ -d "$output_hild_prunning" ]; then
    echo "$output_hild_prunning does exist."
else
    echo "hild prunning was not made, input file for for QC is: ${input_file}"
    output_hild_prunning=${input_file}
fi

#in order to maintain an organizd working space we well create a new directory to contain QC output files
mkdir ${outdirectory}${todays_date}_QC_for_assoc_study

#define input and output directories for QC with plink
input_for_QC=${output_hild_prunning}
output_file_for_QC=${outdirectory}${todays_date}_QC_for_assoc_study/${todays_date}_output_from_QC


#print QC threshold values
echo "already removed high linkage disequilibrium regions, results written in: ${first_output_file_removed_high_ld_regions}"
echo "--Running Plink for Quality Control over ${input_for_QC}"
echo "results of QC will bre written on ${output_file_for_QC}"
echo "--Missingness per SNPs set on ${geno}"
echo "--Missingness per individual set on ${mind}"
echo "--Minor allele frequency set on ${maf}"
echo "--Hardy-Weinberg threshold set on ${hwe}"
echo "--relationship threshold set on ${rel-cutoff}"
echo "--setting criptic relatedness treshold on ${min}"
echo "--keeping allele order"

#perform QC with plink
module load plink/1.9
plink --bfile ${input_for_QC} --geno ${geno} --mind ${mind} --genome --min ${min} --autosome --rel-cutoff ${rel_cutoff} --maf ${maf} --hwe ${hwe} --keep-allele-order --make-bed --out ${output_file_for_QC}
module unload plink /1.9

echo "results of QC saved in: ${output_file_for_QC}"