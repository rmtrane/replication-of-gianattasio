#!/bin/bash

mkdir -p updated_AD_algorithm_comparison
mkdir -p data/SAS/created

# Fetch updated libnames
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/1a_libnames.sas > updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/2_libnames.sas > updated_AD_algorithm_comparison/2_create_lags_etc.sas
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/2_libnames.sas > updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas

# Remove lines starting with libname and add to newly created files
grep -v "^libname*" -i AD_algorithm_comparison/1a.\ Extract\ self-response\ variables\ from\ RANDp\ _\ 2018.01.17.sas >> updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas
grep -v "^libname*" -i AD_algorithm_comparison/2.\ Create\ lags,leads,\ merge\ with\ ADAMS,\ set\ up\ regression\ vars\ _\ 2018.01.17.sas >> updated_AD_algorithm_comparison/2_create_lags_etc.sas
grep -v "^libname*" -i AD_algorithm_comparison/3.\ Assign\ algorithmic\ dementia\ diagnoses\ and\ create\ HRSt\ HRSv\ datasets_\ 2018.03.02.sas >> updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas


