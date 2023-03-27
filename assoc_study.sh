#we now have to create a different  directory to save the results of our logistic regression
mkdir ${outdirectory}${todays_date}_Assoc_results
input_for_assoc_study=${outdirectory}${todays_date}_QC_for_assoc_study/${todays_date}_output_from_QC
output_for_Assoc_study=${outdirectory}${todays_date}_Assoc_results/${todays_date}_results_assoc_study
output_values_of_PCA=${outdirectory}${todays_date}_PCA/ #to be used as covar file

if [ -d "$output_values_of_PCA" ]; then
    echo "$output_values_of_PCA does exist."
    covarfile=${outdirectory}${todays_date}_PCA/covarfile.txt
    pheno_file=${outdirectory}${todays_date}_PCA/pheno.txt
else
    echo "hild prunning was not made, input file for for QC is: ${input_file}"
    covarfile=${path_to_extrafiles}phenos_last.txt
    pheno_file=${path_to_extrafiles}phenos_last.txt
fi


module load plink/1.9
plink --bfile ${input_for_assoc_study} --logistic --keep-allele-order --pheno ${pheno_file} --pheno-name Keloids --covar ${covarfile} --covar-name PC1-PC10 --allow-no-sex  --out ${output_for_Assoc_study}
module unload plink/1.9
#in or
