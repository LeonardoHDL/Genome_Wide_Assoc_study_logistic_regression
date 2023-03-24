#bin/bash




#These module is meant to do ....?
#for the firs step we are creating a specific directory to place all the new outputfiles from 
#the first QC which is removing high ld zones reported in:
mkdir ${outdirectory}${todays_date}_QC
mkdir ${outdirectory}${todays_date}_QC/Removed_complexes

directory_for_hild_prunning=${outdirectory}${todays_date}_removed_high_ld_regions/
set_of_high_ld_regions=${directory_for_hild_prunning}/hild_set
reported_high_ld_zones_file=${extrafiles}high_ld_regions.txt
output_file_removed_high_ld_regions=${directory_for_hild_prunning}/${todays_date}_removed_high_ld_regions

#we must first remove the high linkage disequilibrium regions such as those that contains MHC complexes
module load plink/1.9
plink --bfile ${input_file} --make-set ${reported_high_ld_zones_file} --autosome --write-set  --keep-allele-order --out ${set_of_high_ld_regions}
plink --bfile ${rootname} --exclude ${set_of_high_ld_regions}.set --autosome --keep-allele-order --make-bed --out ${output_file_removed_high_ld_regions}
module unload plink/1.9
