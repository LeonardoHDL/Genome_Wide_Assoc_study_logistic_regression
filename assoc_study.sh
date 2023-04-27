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
plink --bfile ${input_for_assoc_study} --logistic --keep-allele-order --pheno ${pheno_file} --pheno-name Keloids --covar ${covarfile} --covar-name PC1-PC4 --allow-no-sex  --out ${output_for_Assoc_study}
module unload plink/1.9

#after we have completed the assoc study, the result will be a file with form:
#file.assoc.logistic
#this file contains  all the result from the assoc study, but we don't need all
#we just need those that be testing our SNP and the trait
#the rows in that file are the result of a test, results of tests between snp and trait 
#(not covars) are denoted with ADD in the column 'TEST'
#so in order to get only those we will do some piping with the data
echo "Association study completed, now we will get only the results of the ADD tests"
echo "and save them in a new file called ${output_for_Assoc_study}_no_covars.txt"
head -n 1 ${output_for_Assoc_study}.assoc.logistic > ${output_for_Assoc_study}_no_covars.txt
grep ADD  ${output_for_Assoc_study}.assoc.logistic >> ${output_for_Assoc_study}_no_covars.txt


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
#with their MAF count (obtained from general QC script).
#in order to do that we must create a couple of files where values from
#the snps MAFs will be sorted, so as the result values from assoc_study

echo "obtain statistically significant snps and their freqs"
file_for_critical_p_vals=${outdirectory}${todays_date}_Assoc_results/${todays_date}_critical_P_values.txt
output_for_freq_count=${outdirectory}${todays_date}_QC_for_Assoc_study/${todays_date}_freq_report.frqx
results_logistic_no_covars=${output_for_Assoc_study}_no_covars.txt
sorted_pvals=${outdirectory}${todays_date}_Assoc_results/${todays_date}_critical_P_values_sorted.txt
sorted_freq_file=${outdirectory}${todays_date}_QC_for_Assoc_study/${todays_date}_freq_report_sorted.txt
file_with_critcal_snps_and_freqs=${outdirectory}${todays_date}_Assoc_results/${todays_date}_significant_snps_with_freq.txt

echo "setting the critical p value to 0.0000001"
echo "writing the results in ${file_for_critical_p_vals}"
awk '$9 <= 0.0000001' ${results_logistic_no_covars} > ${file_for_critical_p_vals}


#then we have to sort the column that we are gonna use to join both files
#in this case is the SNP column in both files
sort -k2 ${file_for_critical_p_vals} > ${sorted_pvals}
header_pvals=$(head -n 1 ${results_logistic_no_covars}) 

sort -t $'\t' -k2,2 -s "${output_for_freq_count}" > "${sorted_freq_file}"
header_freq=$(head -n 1 ${output_for_freq_count})

#we then use the command join '-1 and -2' specify which should be the common column
join -1 2 -2 2 ${sorted_pvals} ${sorted_freq_file} -o '1.1,1.2,1.3,1.4,2.4,1.5,1.6,1.7,1.8,1.9,2.5,2.6,2.7,2.8,2.9,2.10'> ${file_with_critcal_snps_and_freqs}

header="CHR SNP BP A1 A2 TEST NMISS OR STAT P C(HOM_A1) C(HET) C(HOM_A2) C(HAP_A1) C(HAP_A2) C(MISSING)"
sed -i "1s/.*/$header/" ${file_with_critcal_snps_and_freqs}
