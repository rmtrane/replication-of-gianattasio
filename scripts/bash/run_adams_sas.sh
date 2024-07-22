#!/bin/bash

find data/HRS-unzips/$1/new_sas -iname "*.sas" | while read f
do
    sas $f
done
