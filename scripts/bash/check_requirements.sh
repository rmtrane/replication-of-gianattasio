#!/bin/bash

zipfile="all"

while getopts ":f:" opt; do
    case $opt in
	f) zipfile="$OPTARG" ;;
    esac
done

# echo $file

if [[ ! $zipfile = "all" ]]; then

    if [[ ! -f $zipfile ]]; then
	echo ""
	echo "$zipfile not found. Download from HRS website."
    fi

else
    
    echo ""
    echo "Checking that all .zip files are present in the folder `pwd`/data/HRS-zips."

    # Create array to hold missing files
    missing=()

    # Check ADAMS files
    declare -a adamsWaves=(
	"a"
	"b"
	"trk"
    )

    for wave in "${adamsWaves[@]}";
    do
	file="`pwd`/data/HRS-zips/adams1$wave.zip"

	if [[ ! -f $file ]]; then
	    missing+=("$file")
	fi
    done


    # Check for RAND Version P file
    if [[ ! -f "`pwd`/data/HRS-zips/randhrsp_archive_SAS.zip" ]]; then
	missing+=("`pwd`/data/HRS-zips/randhrsp_archive_SAS.zip")
    fi

    # Check for general HRS files
    declare -a hrsYears=(
	"a95"
	"h96"
	"h98"
	"h00"
	"h02"
	"h04"
	"h06"
	"h08"
	"h10"
    )

    for year in "${hrsYears}";
    do
	datafile=`pwd`/data/HRS-zips/"$year"da.zip
	sasfile=`pwd`/data/HRS-zips/"$year"sas.zip
	
	if [[ ! -f $datafile ]]; then
	    missing+=($datafile)
	fi

	if [[ ! -f $sasfile ]]; then
	    missing+=($sasfile)
	fi
    done

    # Check if Hurd Probabilities zip file is present
    if [[ ! -f "`pwd`/data/HRS-zips/DementiaPredictedProbabilities.zip" ]]; then
	missing+=("`pwd`/data/HRS-zips/DementiaPredictedProbabilities.zip")
    fi

    # If any files not found, print, otherwise print message confirming everything found.
    if [[ ${#missing[@]} -gt 0 ]]; then
	echo "The following files are missing:"
	echo ""
	
	for file in "${missing[@]}";
	do
	    echo "- `basename $file`"
	done
	
	echo ""
	echo "Download the files from the HRS website and place them in the folder data/HRS-zips/"
	exit 2
    else
	echo "All files accounted for!"
	echo ""
    fi
fi
