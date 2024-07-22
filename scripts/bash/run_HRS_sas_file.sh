#!/bin/bash

while getopts ":o:" opt; do
  case $opt in
    o) out="$OPTARG";;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

source="${out:0:3}"

sasfilename="${out%.*}"

sas data/HRS-unzips/$source/new_sas/$sasfilename.sas
