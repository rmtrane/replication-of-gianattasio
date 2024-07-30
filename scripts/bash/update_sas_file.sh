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

# Create folder for new SAS files
mkdir -p `dirname $infolder`/new_sas

## Create new SAS scripts
# First, get filename without path
filename=${file##*/}
filename=${filename%.*}

# Next, create inputfile
inputfile=$dafolder/$filename.da

#echo $file

sed -E "s|^LIBNAME (.*)[[:space:]]*'.*'|LIBNAME \1 '${outfolder}'|I" $file | 
    sed -E "s|^INFILE .* LRECL[[:space:]]*=[[:space:]]*([0-9]+)|INFILE '${inputfile}' LRECL=\1|I" > `dirname $infolder`/new_sas/$filename.sas


#LC_ALL=C sed "s|^LIBNAME .*|LIBNAME ${libname} \"${outfolder}\";|" $file |
#    LC_ALL=C sed "s|^libname .*|LIBNAME ${libname} \"${outfolder}\";|" |
#    LC_ALL=C sed "s|INFILE .*|INFILE \"${inputfile}\" LRECL=1268;|" > `dirname $infolder`/new_sas/$filename.sas
