#!/bin/bash

mkdir -p updated_AD_algorithm_comparison
mkdir -p data/SAS/created

# Fetch updated libnames
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/1a_libnames.sas > updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/2_libnames.sas > updated_AD_algorithm_comparison/2_create_lags_etc.sas
sed "s|ROOTFOLDER|`pwd`|" scripts/SAS/2_libnames.sas > updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas

# Remove lines starting with libname and add to newly created files
grep -v "^libname*" -i AD_algorithm_comparison/1a.\ Extract\ self-response\ variables\ from\ RANDp\ _\ 2018.01.17.sas >> updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas
grep -v "^libname*" -i AD_algorithm_comparison/3.\ Assign\ algorithmic\ dementia\ diagnoses\ and\ create\ HRSt\ HRSv\ datasets_\ 2018.03.02.sas >> updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas

# For 1b, we need to change the %include statement, and add vp observations to self_clean data
sed -E 's|%include "[a-zA-Z:\_. 0-9\-]+"|TARGET|g' AD_algorithm_comparison/1b.\ Extract\ proxy\ variables\ from\ core\ HRS\ _\ 2018.01.17.sas |
    sed "s|TARGET|%include '`pwd`/updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas'|" |
    sed -E 's|(pres_98 pres_00 pres_02 pres_04 pres_06 pres_08 presch_00 presch_02 presch_04 presch_06 presch_08)|\1\n\t\t\t\t\t\t\t\t\tvp_98 vp_00 vp_02 vp_04 vp_06 vp_08|' > updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas

# For 2, we need to add VP to master_ad data                                                                                                                                                                                                                                    
grep -v "^libname*" -i AD_algorithm_comparison/2.\ Create\ lags,leads,\ merge\ with\ ADAMS,\ set\ up\ regression\ vars\ _\ 2018.01.17.sas |
    sed -E 's|(pres_&w = pres_&y; label pres_&w = "TICS president: for wave &w dementia prediction";)|\1\n\t\tvp_\&w = vp_\&y; label vp_\&w = "TICS vice president: for wave \&w dementia prediction";|' >> updated_AD_algorithm_comparison/2_create_lags_etc.sas
