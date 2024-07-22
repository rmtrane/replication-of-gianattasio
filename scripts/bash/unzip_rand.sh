#!/bin/bash

# Create data/HRS-unzips if not already created
mkdir -p data/SAS

unzip data/HRS-zips/randhrsp_archive_SAS.zip -d data/SAS/rand
