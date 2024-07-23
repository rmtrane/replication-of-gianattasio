#!/bin/bash

# Provide password for private HRS files as first argument

# echo $password

while getopts ":f:p:" opt; do
  case $opt in
    f) file="$OPTARG"
    ;;
    p) password="$OPTARG"
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

# echo $file
# echo $password


# Get basename and filename (basename without extension)
basename=${file##*/}
filename=${basename%.*}

# Create data/HRS-unzips if not already created
mkdir -p data/HRS-unzips

# Unzip ADAMS zip file
unzip -P $password $file -d "data/HRS-unzips/$filename"

# Get current wave (A, B, C, D, or CrossWave)
wave=${filename#adams1}

if [ "$wave" = "trk" ]; then
    wave="CrossWave"
else
    wave=`echo $wave | tr 'a-z' 'A-Z'`
    wave="Wave$wave"
fi

# Unzip nested zip folder with SAS scripts
unzip data/HRS-unzips/"$filename"/"$filename"sas.zip -d data/HRS-unzips/"$filename"/sas

# Unzip nested zip folder with data files
unzip data/HRS-unzips/"$filename"/"$filename"da.zip -d data/HRS-unzips/"$filename"/da

# Make sure all file extensions are lower case
find data/HRS-unzips/"$filename"/da -name '*.*' -exec sh -c 'a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" ' {} \;
find data/HRS-unzips/"$filename"/sas -name '*.*' -exec sh -c 'a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" ' {} \;
