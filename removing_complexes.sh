#bin/bash


#These module is meant to remove genomic complexes of human genomic structure
#these modules can alter results in a assoc study or a PCA
#for the firs step we are creating a specific directory to place all the new outputfiles from 
#the first QC which is removing high ld zones reported in:
mkdir ${outdirectory}${todays_date}_QC
mkdir ${outdirectory}${todays_date}_QC/Removed_complexes

directory_for_hild_prunning=${outdirectory}${todays_date}_QC/Removed_complexes/
set_of_high_ld_regions=${directory_for_hild_prunning}hild_set
reported_high_ld_zones_file=${path_to_extrafiles}high_ld_regions.txt
output_file_removed_high_ld_regions=${outdirectory}${todays_date}_QC/Removed_complexes/${todays_date}_removed_hild_complexes

#we must first remove the high linkage disequilibrium regions such as those that contains MHC complexes
module load plink/1.9
plink --bfile ${input_file} --make-set ${reported_high_ld_zones_file} --autosome --write-set  --keep-allele-order --out ${path_to_extrafiles}hild_set
plink --bfile ${input_file} --exclude ${path_to_extrafiles}hild_set.set --autosome --keep-allele-order --make-bed --out ${output_file_removed_high_ld_regions}
module unload plink/1.9

echo "Completed the removal of High LD complexes, now performing QC with:"
echo ${output_file_removed_high_ld_regions}
