#!/bin/bash

mkdir -p data/SAS/ADAMS
mkdir -p logs/ADAMS/

find data/HRS-unzips/$1/new_sas -iname "*.sas" | while read f
do
    filename=`basename ${f%.*}`
    
    sas $f -log logs/ADAMS/"$filename".log
done
