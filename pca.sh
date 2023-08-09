#!/usr/bin/env bash

#what is next is to obtain pca values to be used as covars and also to plott PCA
#we will use plink software to do this
#we will use the output from the previous step as input for this step

#we will also create a new directory to store PCA values
mkdir ${outdirectory}${todays_date}_PCA

#this section is to check if a specified number of pc's was required
if [ -z "$num_PCs" ];
then
    num_PCs=10
    echo "parameter 'num_PCs' or 'p' was not imputed, assigning it to ${num_PCs}"
    
else
    echo "num_PCs set to: ${num_PCs}"
fi 

#define input and output directories todo the PCA with plink software
input_files_for_PCA=${outdirectory}${todays_date}_QC_for_pca/${todays_date}_LD_pruning_for_pca/${todays_date}_output_from_LD_pruning
output_values_of_PCA=${outdirectory}${todays_date}_PCA/${todays_date}_PCA_values_after_QC

#perform pca
echo 'Now performing PCA in the files that we obtained from step 3: output_from_LD_pruning'
echo "we will obtain 10 PCs from plink software"
echo "input file for PCA are: ${input_files_for_PCA}"
module load plink/1.9
plink --bfile ${input_files_for_PCA} --pca 10 --out ${output_values_of_PCA}
module unload plink/1.9
echo "PCA completed, results are in ${output_values_of_PCA}"

#Now that we have obtained our values for PCA we will graph them to check for
#abnormalities or unexpected data organization
#in order to do this we must have an external file called:
#plotting_pca.py

#these file require 4 input arguments in the following order (besides filename)
#1.A file.eigenvec with the first 10 columns
#2.Separete clinical file with matching column to .eigenvec file. This file will be used to
#the plott target. This file muts be named clinical.csv and in format csv
#3.A file.eigenval with just the 1 column
#4.The output directory to place png files of PCA and the final covar file
#which will be used in the Assoc study
plotting_file_python=${path_to_extrafiles}plotting_pca.py
eigenvectors_to_plot=${outdirectory}${todays_date}_PCA/${todays_date}_PCA_values_after_QC.eigenvec
eigenvals_to_plot=${outdirectory}${todays_date}_PCA/${todays_date}_PCA_values_after_QC.eigenval
clinical_file=${path_to_extrafiles}clinical.csv

#we well create a new directory to allocate our PCA plotts(this folder in)
PCA_images__and_files_output_location=${outdirectory}${todays_date}_PCA/


echo "Now plotting PCA using python script: ${plotting_file_python}"
echo "input files for plotting are: ${eigenvectors_to_plot}, ${eigenvals_to_plot} and ${clinical_file}"
echo "output directory for plotting is: ${PCA_images__and_files_output_location}"

#Continue to plotting
module load python38/3.8.3
python3 ${plotting_file_python} ${eigenvectors_to_plot} ${clinical_file} ${eigenvals_to_plot} ${PCA_images__and_files_output_location}
module unload python38/3.8.3
#In the firectory where images were saved it was also saved final covariates file, which will be 
#saved as 'covarfile.txt' and 'pheno.txt' and they will be placed in the same directiry
#such as the results


echo "A pheno.txt and covarfile.txt files were created in ${PCA_images__and_files_output_location}"
echo "PCA images were created in ${PCA_images__and_files_output_location}"

#the files created by pca (eigenvec and eigenval files) have no header, an this header is necessary 
#so that the file can be used for covariates

#comment if you made the python script run
#sed  -i '1i FID IID PAT MAT SEX PHENOTYPE' ${output_values_of_PCA}.eigenvec


echo "PCA completed"