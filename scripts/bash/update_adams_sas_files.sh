#!/bin/bash


while getopts ":d:" opt; do
  case $opt in
    d) folder="$OPTARG";;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

# Create folder for new SAS files
mkdir -p $folder


dirpath=`dirname $folder`
adams=${dirpath##*/}

# Create new SAS script
find $dirpath/sas -iname "*.sas" | while read f
do
    absolutefilename=`readlink -f $f`
    # pathtofolder=`dirname $absolutefilename`

    sasbasename=${f##*/}
    sasfilename=${sasbasename%.*}

    
    # Then we find the line number where the INPUT part of the SAS script starts.
    INPUTLINE=`grep -n "^INPUT" -i $f | cut -d : -f1`


    inputfile="$dirpath"/da/"$sasfilename".da
    newsasfile="$dirpath"/new_sas/"$sasfilename".sas

    
    cp scripts/SAS/newAdamsSASScripts.sas $newsasfile

    sed "s|INPUTFILE|${inputfile}|" $newsasfile > tmp_1.sas
    sed "s|OUTPATH|`pwd`/data/SAS/ADAMS|" tmp_1.sas > tmp_2.sas
    sed "s|FILENAME|${sasfilename}|" tmp_2.sas > $newsasfile

    rm tmp_*.sas
	
    tail -n +"$INPUTLINE" $f >> $newsasfile
done
