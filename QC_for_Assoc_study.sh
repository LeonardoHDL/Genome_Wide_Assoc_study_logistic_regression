#!/bin/bash


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

#now we will create a new directory where to store the QC for the assoc study

mkdir ${outdirectory}${todays_date}_QC_for_Assoc_study

#define the input and output files, we will also generate a report of the frequencies of the SNPs
#input=${outdirectory}${todays_date}_QC_for_pca/Removed_complexes/${todays_date}_removed_hild_complexes
input=${input_file}
output=${outdirectory}${todays_date}_QC_for_Assoc_study/QC_for_Assoc_study
output_for_freq_count=${outdirectory}${todays_date}_QC_for_Assoc_study/${todays_date}_freq_report

echo "Runing QC for Assoc study over ${input}"
echo "--Missingness per SNPs set on ${geno}"
echo "--Missingness per individual set on ${mind}"
echo "--Minor allele frequency set on ${maf}"
echo "--Hardy-Weinberg threshold set on ${hwe}"
echo "--relationship threshold set on ${rel_cutoff}"
echo "--setting criptic relatedness treshold on ${min}"
echo "--keeping allele order"
echo "results of QC will be written to ${output}"


module load plink/1.9
plink --bfile ${input} --geno ${geno} --mind ${mind} --genome --autosome --keep-allele-order --rel-cutoff ${rel_cutoff} --maf ${maf} --hwe ${hwe} --min ${min} --make-bed --out ${output}
plink --bfile ${output} --freqx --keep-allele-order --out ${output_for_freq_count}
module unload plink/1.9


echo "A separate file containing the MAF count of each snp is writed in:"
echo ${output_for_freq_count}
