#!/usr/bin/env python


#import libraries
import pandas as pd
import numpy as np
import io
import os
import sys 

#create a function to read vcf files
def read_vcf(path):
    with open(path, 'r') as f:
        lines = [l for l in f if not l.startswith('##')]
    return pd.read_csv(
        io.StringIO(''.join(lines)),
        dtype={'#CHROM': str, 'POS': int, 'ID': str, 'REF': str, 'ALT': str,
               'QUAL': str, 'FILTER': str, 'INFO': str},
        sep='\t'
    ).rename(columns={'#CHROM': 'CHROM'})

#now we will read the vcf file
VCF_path=sys.argv[1]
VCF=read_vcf(VCF_path)

#we split the info column
info_column_splitted=VCF['INFO'].str.split("(", expand=True)
#due to an expected error we will select only the first two cols
info_column_splitted=info_column_splitted.loc[:,0:1]
#we join the splitted info column with the rest of the vcf
joint_variants_and_info=VCF.join(info_column_splitted)
#delete the info column since we have splitted it and the original info column is not needed anymore
joint_variants_and_info.drop(columns=['INFO'], inplace=True)
#define the new column names
print(joint_variants_and_info.columns)
print(joint_variants_and_info.head())
print(joint_variants_and_info.shape)
new_cols_name=['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'rep=', 'INFO']
joint_variants_and_info.columns=new_cols_name
#now we split the info column again
info_fields=joint_variants_and_info['INFO'].str.split("|", expand=True)
#we delete the last character of the last column
info_fields[13] = info_fields[13].str.replace(')', '')
#we define the names of the columns that we obtained from splitting the info column
names_of_info_fields=['Effect', 'IsLof', 'IsAncestralAllele','DeleteriousMissenseCount','GeneName',
       'GeneId','FractionOfTranscriptsAffected','TranscriptId','HGVS.c','HGVS.p',
       'cDNA_position / cDNA_length', 'CDS_position / CDS_length','Protein_position / Protein_length',
       'TransciptFlags'
       ]
info_fields.columns=names_of_info_fields
#now we join the variant info with the rest of the vcf
variants_with_info=joint_variants_and_info.join(info_fields)
#now we delete the old info field
variants_with_info.drop(columns=['INFO'], inplace=True)
#since indels doesn't work when merging dataframes, we will create a special dataframe for indels
variants_with_info['Numeric_Difference'] = variants_with_info['REF'].apply(len) - variants_with_info['ALT'].apply(len)
#we select only the indels indicated by the numeric difference
variants_with_info_just_indels=variants_with_info[variants_with_info['Numeric_Difference']!=0]
#we later will have to merge this by using CHR:POS:REF:ALT,this is the original dataframe
variants_with_info['SNP']=variants_with_info['CHROM'].astype(str)+':'+variants_with_info['POS'].astype(str)+':'+variants_with_info['REF'].astype(str)+':'+variants_with_info['ALT'].astype(str)
#now we will create a column that will have a letter depending on the sign of the numeric difference
variants_with_info_just_indels['type_of_indel']=variants_with_info_just_indels['Numeric_Difference'].apply(lambda x: 'D' if x>0 else 'I')
#now we will create a column that will have the corrected SNP
variants_with_info_just_indels['SNP_corrected']=variants_with_info_just_indels['CHROM'].astype(str)+':'+variants_with_info_just_indels['POS'].astype(str)+':'+variants_with_info_just_indels['type_of_indel'].astype(str)+':'+variants_with_info_just_indels['Numeric_Difference'].abs().astype(str)
#now we will create the SNP column even if it iswrong, but it will be necessary for merging
variants_with_info_just_indels['SNP']=variants_with_info_just_indels['CHROM'].astype(str)+':'+variants_with_info_just_indels['POS'].astype(str)+':'+variants_with_info_just_indels['REF'].astype(str)+':'+variants_with_info_just_indels['ALT'].astype(str)
#select only columns of interest
variants_with_info_just_indels_just_2columns=variants_with_info_just_indels[['SNP_corrected','SNP']]
#merge the both dataframes, where one of them contain the right SNP identifier
all_types_of_variants=pd.merge(variants_with_info,variants_with_info_just_indels_just_2columns,on='SNP',how='left')
#now we will replace the wrong SNP identifier with the right one
all_types_of_variants.loc[all_types_of_variants['Numeric_Difference'] != 0, 'SNP'] =all_types_of_variants.loc[all_types_of_variants['Numeric_Difference'] != 0, 'SNP_corrected']


#now we will read the output from plink that contains the results of the logistic regression
results_logistic_regression_path=sys.argv[2]
results_logistic_regression=pd.read_table(results_logistic_regression_path, sep='\s+')
#no we will merge the results with the variant info
merged_results_w_variant_info=pd.merge(variants_with_info, results_logistic_regression, on='SNP', how='right')
#we will select only the columns that we need
merged_results_w_variant_info=merged_results_w_variant_info[['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'Effect',
       'IsLof', 'IsAncestralAllele', 'DeleteriousMissenseCount', 'GeneName',
       'GeneId', 'FractionOfTranscriptsAffected', 'TranscriptId', 'HGVS.c',
       'HGVS.p', 'cDNA_position / cDNA_length', 'CDS_position / CDS_length',
       'Protein_position / Protein_length', 'TransciptFlags', 'SNP', 'CHR',
       'BP', 'A1', 'TEST', 'NMISS', 'OR', 'STAT', 'P']]
##now we will also read the freqx file that contains the allele frequencies
freqx_path=sys.argv[3]
freq_report=pd.read_table(freqx_path, sep='\t')
#we select only the columns that we need
freq_report=freq_report[['SNP','C(HOM A1)', 'C(HET)', 'C(HOM A2)',
       'C(HAP A1)', 'C(HAP A2)', 'C(MISSING)']]
#now we will merge the results with the variant info and the allele frequencies
variantInfo_results_and_freqx_merged=pd.merge(merged_results_w_variant_info, freq_report, on='SNP', how='inner')
#we select only the columns that we need and order them
variantInfo_results_and_freqx_merged=variantInfo_results_and_freqx_merged[['CHROM','SNP', 'POS', 'P', 'ID', 'Effect', 'IsLof',
       'IsAncestralAllele', 'DeleteriousMissenseCount', 'GeneName', 'GeneId',
       'FractionOfTranscriptsAffected', 'TranscriptId', 'HGVS.c', 'HGVS.p',
       'cDNA_position / cDNA_length', 'CDS_position / CDS_length',
       'Protein_position / Protein_length', 'TransciptFlags', 'CHR',
        'TEST', 'NMISS', 'OR', 'STAT', 'C(HOM A1)', 'C(HET)',
       'C(HOM A2)', 'C(HAP A1)', 'C(HAP A2)', 'C(MISSING)']]
#now we store this in a csv
path_to_store=sys.argv[4]
variantInfo_results_and_freqx_merged.to_csv(path_to_store, index=False)

#now we will select only those values that are significant
significant_variants=variantInfo_results_and_freqx_merged[variantInfo_results_and_freqx_merged['P']<0.0000005]
#we will store this in a csv
significant_variants_path=sys.argv[5]
significant_variants.to_csv(significant_variants_path, index=False)

#we will also get the top ten most significant variants
topten=variantInfo_results_and_freqx_merged.nsmallest(10, 'P')
#we will store this in a csv
topten_path=sys.argv[6]
topten.to_csv(topten_path, index=False)
