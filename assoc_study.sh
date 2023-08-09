#!/usr/bin/env bash


#we now have to create a different  directory to save the results of our logistic regression
mkdir ${outdirectory}${todays_date}_Assoc_results

#we will use the output of the QC step as input for the assoc study
input_for_assoc_study=${outdirectory}${todays_date}_QC_for_Assoc_study/QC_for_Assoc_study
output_for_Assoc_study=${outdirectory}${todays_date}_Assoc_results/${todays_date}_results_assoc_study
output_values_of_PCA=${outdirectory}${todays_date}_PCA/ #to be used as covar file

if [ -d "$output_values_of_PCA" ]; then
    echo "$output_values_of_PCA does exist."
    covarfile=${outdirectory}${todays_date}_PCA/covarfile.txt
    pheno_file=${outdirectory}${todays_date}_PCA/pheno.txt
else
    echo "PCA script was not run, input fies for covars and extrafiles are in: ${path_to_extrafiles}"
    covarfile=${path_to_extrafiles}covarfile.txt
    pheno_file=${path_to_extrafiles}pheno.txt
fi

echo "input for assoc study is: ${input_for_assoc_study}"
echo "Phenotype file is: ${pheno_file}"
echo "Covar file is: ${covarfile}"
echo "output for assoc study is: ${output_for_Assoc_study}"

module load plink/1.9
plink --bfile ${input_for_assoc_study} --logistic --keep-allele-order --pheno ${pheno_file} --pheno-name Keloids --covar ${covarfile} --covar-name PC1-PC4 --allow-no-sex --autosome --hide-covar  --out ${output_for_Assoc_study}
module unload plink/1.9

#Now we will create a QQ plot (to check for inflation or other problems with our results distribution)
#and also a manhattan plot to watch the results in a graphical way
#in order to do that we will need a extrafile in the extrafile directory that will be an R script
#it needs 3 args (besides Rscript name, which is the first arg) 
#2.file of assoc results only where the values are the ADD (not the PCA assoc results)
#3.output for QQ plot
#4.output for manhattan plot
results_of_assoc_just_snps=${output_for_Assoc_study}
path_R_script=${path_to_extrafiles}assoc_results_plotts.R
output_for_QQ=${outdirectory}${todays_date}_Assoc_results/${todays_date}_QQplot.png
output_for_man=${outdirectory}${todays_date}_Assoc_results/${todays_date}_MAN_plot.png

module load r/4.2.2
Rscript --vanilla ${path_R_script} ${results_of_assoc_just_snps} ${output_for_QQ} ${output_for_man}
module unload r/4.2.2

echo "manhattan and QQ plots created, they are in: ${outdirectory}${todays_date}_Assoc_results/"

#one of the final steps is to create a file where statistically significant snps are written together 
#with their MAF count (obtained from general QC script) and the variant info obtained
#from the VCF file
echo "obtain statistically significant snps and their freqs"
file_for_critical_p_vals=${outdirectory}${todays_date}_Assoc_results/${todays_date}_critical_P_values.csv
SNPs_and_freqs=${outdirectory}${todays_date}_Assoc_results/${todays_date}_SNPs_and_freqs.csv
#now we will run a python script that merges the variant info with the results of the assoc study and the freqs
path_to_python_script=${path_to_extrafiles}adding_variant_info.py

#it requires 5 args:
#1. VCF file
path_to_vcf='/mnt/Guanina/cvan/data/Keloids_F2/Resources/VariantAnnotation/UCHC_Freeze_Two.rep.vcf'
#2. results of assoc study
results_logistic_no_covars=${output_for_Assoc_study}.assoc.logistic
#3. freqs file
output_for_freq_count=${outdirectory}${todays_date}_QC_for_Assoc_study/${todays_date}_freq_report.frqx
#4. path to the output file which is a csv file
#5. path to the second output file with the critical p values 
#6 path to the top 10 most significant snps
topten=${outdirectory}${todays_date}_Assoc_results/${todays_date}_top10.csv
module load python38/3.8.3
python3 ${path_to_python_script} ${path_to_vcf} ${results_logistic_no_covars} ${output_for_freq_count} ${SNPs_and_freqs} ${file_for_critical_p_vals} ${topten}
module unload python38/3.8.3