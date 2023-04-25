#!/bin/bash

#now that we have done the high ld zones prunning me will continue to do a General QC for an Association 
#study

### Next lines specify that if no arguments for QC are given, then they'll be set
#to a default value
if [ -z "$geno" ]; #geno is the parameter for missingness per SNP
then
    geno=0.1
    echo "parameter 'geno' or 'g' was not imputed, assigning it to ${geno}"
    
else
    echo "geno parameter was imputed by user, set to: ${geno}"
fi 
####
if [ -z "$mind" ]; #mind is the parameter for missingness per individual
then
    mind=0.1
    echo "parameter 'mind' or 'm' was not imputed, assigning it to ${mind}"
    
else
    echo "mind parameter was imputed by user, set to: ${mind}"
fi 
####
if [ -z "$maf" ]; #maf is the parameter for minor alele frequency
then
    maf=0.01
    echo "parameter 'maf' or 'a' was not imputed, assigning it to ${maf}"
    
else
    echo "maf parameter was imputed by user, set to: ${maf}"
fi 
##
if [ -z "$hwe" ]; #hwe is the parameter for Hardy-Weinberg equilibrium threshold
then
    hwe=0.0000001
    echo "parameter 'hwe' or 'h' was not imputed, assigning it to ${geno}"
    
else
    echo "HWE parameter was imputed by user, set to: ${hwe}"
fi 
###
if [ -z "$min" ]; #min is the parameter for cryptic relatedness threshold
then
    min=0.01
    echo "parameter 'min' or 'n' was not imputed, assigning it to ${min}"
    
else
    echo "min parameter was imputed by user, set to: ${min}"
fi 
###
if [ -z "$rel_cutoff" ]; #rel_cutoff is the parameter for relatedness threshold
then
    rel_cutoff=0.025
    echo "parameter 'rel_cutoff' or 'r' was not imputed, assigning it to ${rel_cutoff}"
    
else
    echo "rel_cutoff was imputed by user, set to: ${rel_cutoff}"
fi 
###

#next part is meant to chek whether the previous step (hild removal) was made
#if not, then the input file for QC is the unprocesed data defined in the master script as 'input_file'
#and not the output from removing_complexes.sh
output_hild_prunning=${outdirectory}${todays_date}_QC/Removed_complexes/

#this parte cheks whether the folder for hild prunning exists, and if it does, then the input file for QC is the output from removing_complexes.sh
#if not then the input file for QC is the unprocessed data
if [ -d "$output_hild_prunning" ]; then
    echo "$output_hild_prunning does exist."
    echo "removal of high linkage disequilibrium regions was done, those results are written in: ${first_output_file_removed_high_ld_regions}"
    output_hild_prunning=${outdirectory}${todays_date}_QC/Removed_complexes/${todays_date}_removed_hild_complexes
else
    echo "removal of high linkage disequilibrium regions was not made, input file for for QC is: ${input_file}"
    echo "creating folder for QC"
    mkdir ${outdirectory}${todays_date}_QC
    output_hild_prunning=${input_file}
fi

#in order to maintain an organizd working space we well create a new directory to contain QC output files
mkdir ${outdirectory}${todays_date}_QC/${todays_date}_generalQC

#define input and output directories for QC with plink
input_for_QC=${output_hild_prunning}
output_file_for_QC=${outdirectory}${todays_date}_QC/${todays_date}_generalQC/${todays_date}_output_from_QC
output_for_freq_count=${outdirectory}${todays_date}_QC/${todays_date}_generalQC/${todays_date}_freq_report

#print QC threshold values
echo "--Running Plink for Quality Control over ${input_for_QC}"
echo "--Missingness per SNPs set on ${geno}"
echo "--Missingness per individual set on ${mind}"
echo "--Minor allele frequency set on ${maf}"
echo "--Hardy-Weinberg threshold set on ${hwe}"
echo "--relationship threshold set on ${rel_cutoff}"
echo "--setting criptic relatedness treshold on ${min}"
echo "--keeping allele order"
echo "results of QC will be written to ${output_file_for_QC}"


#perform QC with plink
module load plink/1.9
plink --bfile ${input_for_QC} --geno ${geno} --mind ${mind} --genome --min ${min} --autosome --rel-cutoff ${rel_cutoff} --maf ${maf} --hwe ${hwe} --keep-allele-order --make-bed --out ${output_file_for_QC}
plink --bfile ${output_file_for_QC} --freqx --keep-allele-order --out ${output_for_freq_count}
module unload plink /1.9

echo "results of QC saved in: ${output_file_for_QC}"
#each result must have its freq

echo "Done with QC, files produced:"
echo ${output_file_for_QC}
echo "A separate file containing the MAF count of each snp is writed in:"
echo ${output_for_freq_count}