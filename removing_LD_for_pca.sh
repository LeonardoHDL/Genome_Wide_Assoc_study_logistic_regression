#!/usr/bin/env bash


#this script is a step in the process of automatizing a GWAS
#this script will remove LD from the data
#This script must be run after QC and removal of High LD and other complex regions


#we must first define the variables that will be used in this script
#we also have to create a new folder to store the results of this step

mkdir ${outdirectory}${todays_date}_QC/${todays_date}_LD_pruning_for_pca
input_for_LD_pruning=${outdirectory}${todays_date}_QC/${todays_date}_generalQC/${todays_date}_output_from_QC
output_for_LD_pruning=${outdirectory}${todays_date}_QC/${todays_date}_LD_pruning_for_pca/${todays_date}_output_from_LD_pruning
set_of_snps_to_prune=${outdirectory}${todays_date}_QC/${todays_date}_LD_pruning_for_pca/${todays_date}_set_of_snps_to_prune
module load plink/1.9
plink --bfile ${input_for_LD_pruning} --indep-pairwise 50 5 0.5 --out ${set_of_snps_to_prune}
plink --bfile ${input_for_LD_pruning} --extract ${set_of_snps_to_prune}.prune.in --make-bed --out ${output_for_LD_pruning}
module unload plink /1.9
