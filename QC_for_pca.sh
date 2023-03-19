#!/bin/bash
#this script is meant to automatize a QC for a PCA


geno=0.1	#Missingness per allele
mind=0.1	#Missingness per individual
maf=0.05	#Minor alele frequency
hwe=0.0000001 #Hardy-Weinberg
min=0.2 #Cryptic relatedness
rel_cutoff=0.025
rootname='/mnt/Guanina/cvan/data/Keloids_F2/WES/Plink/UCHC_Freeze_Two.GL.splitmulti'
removed_high_ld_regions='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230310_automatizing_scripts_and_trials/'
high_ld_zones='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230222_QC_for_Assoc_study/20230227_PCA_results_and_extrafiles/high_ld_regions.txt'




#we must first remove the high linkage disequilibrium regions such as those that contains MHC complexes

plink --file mydata --make-set high_ld_regions.txt --write-set --out 
plink --file mydata --exclude hild.set --recode --out mydatatrimmed


echo "--Running Plink for Quality Control over ${rootname}"
echo "--Missingness per SNPs set on ${geno}"
echo "--Missingness per individual set on ${mind}"
echo "--Minor allele frequency set on ${maf}"
echo "--Hardy-Weinberg threshold se on ${hwe}"
echo "--relationship threshold set on ${rel-cutoff}"


module load plink/1.9

plink --bfile ${rootname} --geno ${geno} --mind ${mind} --genome --min ${min} --rel-cutoff ${rel_cutoff} --maf ${maf} --hwe ${hwe} --keep-allele-order --make-bed --out ${outfile}

module unload plink /1.9




echo "results of QC saved in: ${outfile}"
