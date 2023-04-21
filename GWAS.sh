#!/bin/bash
#this script is meant to automatize a QC for a PCA


#in the outdirectory new folders will be created to place the results of each step of this study
outdirectory='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230310_automatizing_scripts_and_trials/'
path_to_extrafiles='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230227_PCA_results_and_extrafiles/'
export outdirectory
export path_to_extrafiles
#Directory where the raw data are stored
#data must be in .b format.
input_file=/mnt/Guanina/cvan/data/Keloids_F2/WES/Plink/UCHC_Freeze_Two.GL.splitmulti
export input_file

#THis will help us to automatize a little bit more this study
#not a necessary step, if some arguments are not specified then they'll be set to default
#values
while getopts i:x:g:m:a:h:n:r:o:p flag
do
    case "${flag}" in
		i) input_file=${OPTARG}
        export input_file ;;	#Rootname of the .ped and .map files
        x) extrafiles=${OPTARG}
        export extrafiles;; # dir to Extrafiles where: clin file, covar file, pheno file, plott and hid complexes
		g) geno=${OPTARG}
        export geno;;	#Missingness per allele
		m) mind=${OPTARG}
        export mind;; #Missingness per individual
		a) maf=${OPTARG}
        export maf;; #Minor alele frequency
		h) hwe=${OPTARG}
        export hwe;; #Hardy-Weinberg
		n) min=${OPTARG}
        export min;;  #Cryptic relatedness
        r) rel_cutoff=${OPTARG}
        export rel_cutoff #relationship cutoff, cousins=0.025
        ;;
		o) outdirectory=${OPTARG}
        export outdirectory;; #output directory (not a file), where some new folders will be created
		p) num_PCs=${OPTARG}
        export  num_PCs;;
    esac
done

#we define the date so that output files be called with a useful name
todays_date=$(date +"%Y%m%d")
export todays_date

##comment if you dont want that step to be done
#only removing_complexes.sh and pca.sh can be commented
#./removing_complexes.sh
#./general_QC.sh
#./pca.sh
./assoc_study.sh
#nohup