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

sed "s|PUTPATHHERE|${folder}|" scripts/SAS/RANDcreateFormats.sas > $folder/createFormats.sas

sas $folder/createFormats.sas
