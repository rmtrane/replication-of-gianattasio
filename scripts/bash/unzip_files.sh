#!/bin/bash

while getopts ":f:p:" opt; do
  case $opt in
    f) file="$OPTARG"
    ;;
    p) pword="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done


# Get basename and filename (basename without extension)
basename=${file##*/}
filename=${basename%.*}

# Create data/HRS-unzips if not already created
mkdir -p data/HRS-unzips


if [ -z ${pword+x} ]; then
    ## HRS Files
    echo "No password given. Assuming .zip file is NOT an ADAMS file."

    mkdir -p data/HRS-unzips/"$filename"

    # Unzip da.zip and sas.zip files
    unzip -q "$file"da.zip -d data/HRS-unzips/"$filename"/da
    unzip -q "$file"sas.zip -d data/HRS-unzips/"$filename"/sas

    
else
    ## ADAMS files
    echo "Password is given. Assuming .zip file IS an ADAMS file."

    # Unzip ADAMS zip file
    unzip -q -P $pword $file -d "data/HRS-unzips/$filename"

    # Unzip nested zip folder with SAS scripts
    unzip -q data/HRS-unzips/"$filename"/"$filename"sas.zip -d data/HRS-unzips/"$filename"/sas

    # Unzip nested zip folder with data files
    unzip -q data/HRS-unzips/"$filename"/"$filename"da.zip -d data/HRS-unzips/"$filename"/da
    
fi

# Make sure all file names are lower case
find data/HRS-unzips/"$filename"/{sas,da} -name '*.*' | while read f
do
    newfile=`basename $f | tr "[:upper:]" "[:lower:]"`
    mv $f `dirname $f`/"$newfile"
done


