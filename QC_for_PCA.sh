#!/bin/bash

#now that we have done the high ld zones prunning me will continue to do a General QC for PCA

### Next lines specify the parameters to be used in the QC for PCA
geno=0.1
mind=0.1
maf=0.01
hwe=0.0000001
min=0.2
rel_cutoff=0.025

#next part is meant to chek whether the previous step (hild removal) was made
#if not, then the input file for QC is the unprocesed data defined in the master script as 'input_file'
#and not the output from removing_complexes.sh
output_hild_prunning=${outdirectory}${todays_date}_QC_for_pca/Removed_complexes/

#this parte cheks whether the folder for hild prunning exists, and if it does, then the input file for QC is the output from removing_complexes.sh
#if not then the input file for QC is the unprocessed data
if [ -d "$output_hild_prunning" ]; then
    echo "$output_hild_prunning does exist."
    echo "removal of high linkage disequilibrium regions was done, those results are written in: ${first_output_file_removed_high_ld_regions}"
    output_hild_prunning=${outdirectory}${todays_date}_QC_for_pca/Removed_complexes/${todays_date}_removed_hild_complexes
else
    echo "removal of high linkage disequilibrium regions was not made, input file for the QC of PCA is: ${input_file}"
    echo "creating folder for QC"
    mkdir ${outdirectory}${todays_date}_QC_for_pca
    output_hild_prunning=${input_file}
fi

#in order to maintain an organizd working space we well create a new directory to contain QC output files
mkdir ${outdirectory}${todays_date}_QC_for_pca/${todays_date}_generalQC

#define input and output directories for QC with plink
input_for_QC=${output_hild_prunning}
output_file_for_QC=${outdirectory}${todays_date}_QC_for_pca/${todays_date}_generalQC/${todays_date}_output_from_QC

#print QC threshold values

echo "Runing QC for PCA"
echo "--Running Plink for PCA Quality Control over ${input_for_QC}"
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
module unload plink /1.9

echo "results of QC for PCA saved in: ${output_file_for_QC}"
#each result must have its freq

echo "Done with QC for PCA, files produced:"
echo ${output_file_for_QC}