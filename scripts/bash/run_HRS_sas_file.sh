#!/bin/bash

find data/HRS-unzips/h*/new_sas -iname "*.sas" | while read f
do
    sas $f
done
