#!/bin/bash


#######
## This script takes a SAS file, updates the paths, and saves and
## updated SAS file to the folder ../new_sas/ (relative to where the original
## SAS file was located.)

while getopts ":f:" opt; do
  case $opt in
    f) file="$OPTARG";;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

# Get important folders with absolute paths
infolder=`dirname $(readlink -f $file)`
dafolder=`dirname $infolder`/da
outfolder=${infolder%/data/*}/data/SAS

# If ADAMS file, add /ADAMS to outfolder, otherwise add /HRS
case "$file" in
    *adams*)
	outfolder=$outfolder/ADAMS;;
    *h*/sas/*)
	outfolder=$outfolder/HRS;;
esac

# Create folder for new SAS files
mkdir -p `dirname $infolder`/new_sas

## Create new SAS scripts
# First, get filename without path
filename=${file##*/}
filename=${filename%.*}

# Next, create inputfile
inputfile=$dafolder/$filename.da

LC_ALL=C sed "s|LIBNAME .*|LIBNAME ADAMS1 \"${outfolder}\";|" $file |
    LC_ALL=C sed "s|LIBNAME .*|LIBNAME EXTRACT \"${outfolder}\";|" $file |
    LC_ALL=C sed "s|INFILE .*|INFILE \"${inputfile}\" LRECL=1268;|" > `dirname $infolder`/new_sas/$filename.sas
