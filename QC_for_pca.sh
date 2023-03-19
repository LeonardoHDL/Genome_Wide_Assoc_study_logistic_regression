#!/bin/bash
#this script is meant to automatize a QC for a PCA

todays_date=$(date +"%Y%m%d")

#in the base_path directory some new folders we'll be created

base_path='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230310_automatizing_scripts_and_trials/'


#for the firs step we are creating a specific directory to place all the new outputfiles from 
#the first QC which is removing high ld zones reported in:

mkdir ${base_path}${todays_date}_removed_high_ld_regions
directory_for_hild_prunning=${base_path}${todays_date}_removed_high_ld_regions

#setting QC parameters, so as directories where necessary files are needed (high_ld_regions.txt,
#phenotype files and covar files)

geno=0.1	#Missingness per allele
mind=0.1	#Missingness per individual
maf=0.05	#Minor alele frequency
hwe=0.0000001 #Hardy-Weinberg
min=0.2 #Cryptic relatedness
rel_cutoff=0.025
rootname=/mnt/Guanina/cvan/data/Keloids_F2/WES/Plink/UCHC_Freeze_Two.GL.splitmulti
set_of_high_ld_regions=${directory_for_hild_prunning}/hild_set.set
reported_high_ld_zones_file=/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230227_PCA_results_and_extrafiles/high_ld_regions.txt
first_output_file_removed_high_ld_regions=${directory_for_hild_prunning}/${todays_date}_removed_high_ld_regions

#we must first remove the high linkage disequilibrium regions such as those that contains MHC complexes
module load plink/1.9

plink --bfile ${rootname} --make-set ${reported_high_ld_zones_file} --write-set --out ${set_of_high_ld_regions}
plink --bfile ${rootname} --exclude ${set_of_high_ld_regions} --recode --out ${first_output_file_removed_high_ld_regions}

module unload plink/1.9



#Now that we have done the high ld zones prunning me will continue to do a General QC for an Association 
#study

#in order to maintain an organizd working space we well create a new directory to contain QC output files
mkdir ${base_path}${todays_date}_QC_for_assoc_study
input_for_QC=${first_output_file_removed_high_ld_regions}
output_file_for_QC= ${base_path}_QC_for_assoc_study/${todays_date}_output_from_QC



echo "already removed high linkage disequilibrium regions, results written in: ${first_output_file_removed_high_ld_regions}"
echo "--Running Plink for Quality Control over ${input_for_QC}"
echo "--Missingness per SNPs set on ${geno}"
echo "--Missingness per individual set on ${mind}"
echo "--Minor allele frequency set on ${maf}"
echo "--Hardy-Weinberg threshold set on ${hwe}"
echo "--relationship threshold set on ${rel-cutoff}"
echo "setting criptic relatedness treshold on ${min}"
echo "keeping allele order"


module load plink/1.9

plink --bfile ${input_for_QC} --geno ${geno} --mind ${mind} --genome --min ${min} --rel-cutoff ${rel_cutoff} --maf ${maf} --hwe ${hwe} --keep-allele-order --make-bed --out ${output_file_for_QC}

module unload plink /1.9




echo "results of QC saved in: ${output_file_for_QC}"
