#!/bin/bash

#this script is meant to automatize a whole GWAS

#this script should be run as: ./GWAS.sh -i input_file -x extrafiles -g geno -m mind -a maf -h hwe -n min -r rel_cutoff -o outdirectory -p num_PCs
#parameters are not mandatory, if not specified then they'll be set to default values

#in the outdirectory new folders will be created to place the results of each step of this study
outdirectory='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230310_automatizing_scripts_and_trials/'

#it is import to note that this directory is where the extrafiles are stored, these extrafiles are:
#covar file, pheno file, clin file, plott files to obtain Manhattan, QQ and PCA
#covar and pheno file are the same as in the PCA step, but you must place them there if you skip PCA step
#if you don't have this directory and the mentioned files, it's neccesary change the directory
#where this extrafiles are stored.
#these extrafiles are necessary for the PCA and association study
#in this directory you must place the results of a previous PCA (eigenvec) if you want to skip PCA step 
#in this study. You must also have a 
#these must be named as follows: eigenvec file must be named as: covarfile.txt, and pheno file must be named as: pheno.txt
path_to_extrafiles='/mnt/Guanina/cvan/data/Keloids_F2/Analysis/leo_analysis/20230227_PCA_results_and_extrafiles/'

#
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
echo "directory to be used as output: ${outdirectory}"
echo "directory to extrafiles: ${path_to_extrafiles}"
echo "input file: ${input_file}"

##comment if you dont want that step to be done
#only removing_complexes.sh, pca.sh, and LD prunning can be commented, the others are necessary
./removing_complexes.sh #this script remove regions that may affect PCA values and the association study
./QC_for_PCA.sh #this script is meant to do a QC for the PCA step
./removing_LD_for_pca.sh #this script is meant to remove LD regions for the PCA step
./pca.sh #this script is meant to do a PCA
./QC_for_Assoc_study.sh #this script is meant to do a QC for the association study
./assoc_study.sh #this script is meant to do an association study
