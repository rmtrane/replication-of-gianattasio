# Replication of Gianattasio et al. (2019)
Ralph Møller Trane

## Introduction

This repo aims at replicating the results of Gianattasio et al. (2019).
The greater idea behind this is a desire to implement the algorithms in
R for future research purposes, but in a way that is consistent with
what has previously been done. Therefore, we create this pipeline with
instructions to

1.  Download the needed files from the HRS website
2.  

## Run

Unzip all .zip files downloaded from HRS website. Will throw an error if
any needed .zip files are missing. This unzips the files to the folder
`data/HRS-unzips/`.

    make unzip_all password="placeyourpasswordfromHRSforADAMSzipfileshere"

Create a formats file for RAND data.

    make data/SAS/rand/formats.sas7bcat

Update all sas files. This replaces file paths in the SAS files from the
HRS and ADAMS SAS files downloaded from HRS website. The updated SAS
files are placed in `data/HRS-unzips/{subdir}/new_sas` where `{subdir}`
refers to the name of the .zip file that was unzipped.

    make update_all_sas

Next, we run all the SAS files to create SAS data sets for use later.
The created datasets are placed in the `data/SAS/{HRS,ADAMS}` folders.

    make run_all_sas

Now, we need to download the SAS scripts used by Gianattasio et al.
(2019). The next command clones [their GitHub
repo](https://www.github.com/powerepilab/AD_algorithm_comparison) and
checks out the commit that was used for this work. (As of the creation
of this, the most recent commit is the used commit, but in case of any
future changes, we fix the used commit.)

    make AD_algorithm_comparison

The filepaths in the just downloaded SAS scripts need to be updated as
well.

    make update_AD_algorithm_comparison

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-gianattasioComparisonMethodsAlgorithmic2019"
class="csl-entry">

Gianattasio, Kan Z., Qiong Wu, M. Maria Glymour, and Melinda C. Power.
2019. “Comparison of Methods for Algorithmic Classification of Dementia
Status in the Health and Retirement Study.” *Epidemiology* 30 (2): 291.
<https://doi.org/10.1097/EDE.0000000000000945>.

</div>

</div>
