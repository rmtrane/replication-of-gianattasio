#!/bin/bash

while getopts ":f:" opt; do
    case $opt in
	f) file="$OPTARG" ;;
    esac

    case $OPTARG in
	-*) echo "Option $opt needs a valid argument"
    esac
done

# Get basename and filename (basename without extension
basename=${file##*/}
filename=${basename%.*}


mkdir -p data/HRS-unzips/$filename

# Unzip h%%da.zip and h%%sas.zip
unzip "$file"da.zip -d data/HRS-unzips/"$filename"/da
unzip "$file"sas.zip -d data/HRS-unzips/"$filename"/sas

# Make sure all file extensions are lower case
find data/HRS-unzips/"$filename"/{sas,da} -name '*.*' | while read f
do
    ext=`echo "${f##*.}" | tr "[:upper:]" "[:lower:]"`
    newfile="${f%.*}"

    mv $f "$newfile"."$ext"

done
