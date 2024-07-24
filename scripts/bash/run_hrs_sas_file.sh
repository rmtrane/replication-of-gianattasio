#!/bin/bash

mkdir -p data/SAS/HRS
mkdir -p logs/HRS

find data/HRS-unzips/{a,h}*/new_sas -iname "*.sas" | while read f
do
    filename=`basename ${f%.*}`
    
    sas $f -log logs/HRS/"$filename".log
done
