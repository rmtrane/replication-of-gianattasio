#!/bin/bash

endFirstPart=`grep -n "LKW not available for 1998 proxy respondents" updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas | cut -d ":" -f1`
beginSecondPart=`grep -n "1998: no proxy for LKW" updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas | cut -d ":" -f1`


head -n $endFirstPart updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas > updated_AD_algorithm_comparison/3_tmp.sas

cat scripts/SAS/3_hurdprobinput.sas >> updated_AD_algorithm_comparison/3_tmp.sas

tail -n +"$beginSecondPart" updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas >> updated_AD_algorithm_comparison/3_tmp.sas

sed "s|ROOT|`pwd`|" updated_AD_algorithm_comparison/3_tmp.sas > 3_create_training_and_validation_datasets.sas

rm updated_AD_algorithm_comparison/3_tmp.sas
