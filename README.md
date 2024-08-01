# Replication of Gianattasio et al. (2019)
Ralph Møller Trane

## Introduction

This repo aims at replicating the results of Gianattasio et al. (2019).
The greater idea behind this is a desire to implement the algorithms in
R for future research purposes, specifically validating the main
findings from Gianattasio et al. (2019) by way of analyzing WLS data. To
that end, we want to ensure that our implementation of the algorithms
are aligned with previous implementations. Therefore, we create this
pipeline with instructions to recreate the training and validation
datasets from Gianattasio et al. (2019) that can serve to ensure the
correctness of our implementations of algorithms.

## Requirments

This repo was developed for use on a linux machine with a working
installation of R and SAS available. We provide a `Makefile` to easily
recreate the training and validation datasets. The main pieces of
software used are

- `SAS` version 9.4 with analytical products
  - `SAS/STAT 15.3`
  - `SAS/ETS 15.3`
  - `SAS/OR 15.3`
  - `SAS/IML 15.3`
  - `SAS/QC 15.3`
- `R 4.4.0` with the following packages installed:
  - `haven` version `2.5.4`
  - `readr` version `2.1.5`
  - `tidyr` version `1.3.1`
  - Things will most likely also work with previous versions
- `Make` version `4.2.1`

## Step-by-step guide

We will go through the creation of the validation and test datasets
step-by-step below. However, to simply quickly and easily create the
data files, you can clone this repo to your local machine, download the
files mentioned below to the folder `data/HRS-zips`, then run `make all`
from the root directory of this repo. Note that the zip-files with the
ADAMS data are locked with a password. If running the code below
locally, replace `MYPASSWORD` with the password provided by HRS when you
requested access to the ADAMS data.

    git clone https://github.com/rmtrane/replication-of-gianattasio.git ./

    cd replication-of-gianattasio/

    mkdir data/HRS-zips # put downloaded .zip files here

    make all password=MYPASSWORD

### Prepare the data from HRS

#### Download appropriate files

The following .zip files should be downloaded from the [HRS Data
Downloads site](https://hrsdata.isr.umich.edu/data-products/) and placed
in the `data/HRS-zips` folder. We include links to data pages with
details for each set of files, and also direct links for download (file
names formatted as `file.zip` will take you straight to download the
given file). A login is needed to download the data.

Note: make sure your browser does not automatically open files when
downloaded. If .zip files are automatically opened, they will be
unzipped, and not fit the patterns expected. (On Safari on macOS: got
Settings -\> General -\> uncheck ‘Open “safe” files after downloading’.)

- HRS Survey Data:
  - [1998 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/1998-hrs-core):
    [`h98da.zip`](https://hrsdata.isr.umich.edu/data-file-download/5515)
    and
    [`h98sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/5625)
  - [2000 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2000-hrs-core):
    [`h00da.zip`](https://hrsdata.isr.umich.edu/data-file-download/5508)
    and
    [`h00sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/5640)
  - [2002 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2002-hrs-core):
    [`h02da.zip`](https://hrsdata.isr.umich.edu/data-file-download/5506)
    and
    [`h02sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/5637)
  - [2004 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2004-hrs-core):
    [`h04da.zip`](https://hrsdata.isr.umich.edu/data-file-download/5516)
    and
    [`h04sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/5645)
  - [2006 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2006-hrs-core):
    [`h06da.zip`](https://hrsdata.isr.umich.edu/data-file-download/9480)
    and
    [`h06sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/9483)
  - [2008 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2008-hrs-core):
    [`h08da.zip`](https://hrsdata.isr.umich.edu/data-file-download/5510)
    and
    [`h08sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/5652)
  - [2010 HRS
    Core](https://hrsdata.isr.umich.edu/data-products/2010-hrs-core):
    [`h10da.zip`](https://hrsdata.isr.umich.edu/data-file-download/9464)
    and
    [`h10sas.zip`](https://hrsdata.isr.umich.edu/data-file-download/9466)
- RAND HRS Data:
  - We need an older version of the RAND data, the so-called Version P.
    This can be found under [archived data
    versions](https://hrsdata.isr.umich.edu/data-products/rand-hrs-archived-data-products).<br>
    The file needed: - RAND HRS Version P
    [`randhrsp_archive_SAS.zip`](https://hrsdata.isr.umich.edu/data-file-download/5414)
- ADAMS Data:
  - From the main HRS Data Downloads page, navigate to [HRS Sensitive
    Health
    Data](https://hrsdata.isr.umich.edu/data-products/sensitive-health).
    Note: additional permissions are needed to access this part of the
    data.<br> The files to be downloaded are:
    - [Wave
      A](https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-wave):
      [adams1a.zip](https://hrsdata.isr.umich.edu/data-file-download/5539)
    - [Wave
      B](https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-wave-b):
      [adams1b.zip](https://hrsdata.isr.umich.edu/data-file-download/5616)
    - [CrossWave](https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-cross-wave-tracker-file):
      [adams1trk.zip](https://hrsdata.isr.umich.edu/data-file-download/5570)
- Hurd Probabilities:
  - These are provided as a “Contributed Project” on the HRS website;
    follow [this direct
    link](https://hrsdata.isr.umich.edu/data-products/dementia-predicted-probabilities-files)
    to the page where the following zip file can be downloaded:
    - [DementiaPredictedProbabilities.zip](https://hrsdata.isr.umich.edu/data-file-download/5578)

#### Unzip all files

For the `adams1X.zip` files, unzip them and move the resulting folders
to `data/HRS-unzips`. In each of the folders, you will find additional
`.zip` files. Unzip the two called `adams1Xda.zip` and `adams1Xsas.zip`.
Rename them to `da.zip` and `sas.zip`, respectively.

For the `DementiaPredictedProbabilities.zip` and
`randhrs_p_archive_SAS.zip` files, unzip them and move the content of
the folders to `data/SAS/hurd` and `data/SAS/rand`, respectively.

Finally, all the `hXXXX.zip` files are in pairs: `hXXda.zip` and
`hXXsas.zip`. Unzip each pair, and move the resulting folders to
`data/HRS-unzips/hXX`.

When completed, you should have a folder structure similar to what is
illustrated below. I’ve excluded the files in the `da` and `sas`
subfolders since there are a lot… We’ll get back to these soon.

    data/HRS-unzips
    ├── a95
    │   ├── da
    │   └── sas
    ├── adams1a
    │   ├── da
    │   └── sas
    ├── adams1b
    │   ├── da
    │   └── sas
    ├── adams1trk
    │   ├── da
    │   └── sas
    ├── h00
    │   ├── da
    │   └── sas
    ├── h02
    │   ├── da
    │   └── sas
    ├── h04
    │   ├── da
    │   └── sas
    ├── h06
    │   ├── da
    │   └── sas
    ├── h08
    │   ├── da
    │   └── sas
    ├── h10
    │   ├── da
    │   └── sas
    ├── h96
    │   ├── da
    │   └── sas
    └── h98
        ├── da
        └── sas
    data/SAS
    ├── hurd
    │   ├── DescriptionOfPredictedProbabilities.pdf
    │   ├── pdem_withvarnames.dta
    │   └── pdem_withvarnames.sas7bdat
    └── rand
        ├── ArchiveREADME.pdf
        ├── incwlth_p.sas7bdat
        ├── randhrs_P.pdf
        ├── randiwp.pdf
        ├── rndhrs_p.sas7bdat
        └── sasfmts.sas7bdat

#### Update SAS scripts

#### Run SAS scripts

### Prepare SAS scripts to create training and validation data

#### Download from [`powerepilab/AD_algorithm_comparison`](https://github.com/powerepilab/AD_algorithm_comparison)

#### Adjust SAS scripts

### Create training and validation data

## Checks

To make sure everything worked as intended, we recreate Table 1 of
Gianattasio et al. (2019).

<details>
<summary>
R code for recreating Table 1
</summary>

First, the used libraries and reading in the data that was created from
the SAS.

``` r
library(tidyverse)
```

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(gt)
library(gtsummary)

hrs_training <- haven::read_sas(here::here("data/SAS/created/hrst_2018_0302.sas7bdat"))
hrs_validation <- haven::read_sas(here::here("data/SAS/created/hrsv_2018_0302.sas7bdat"))

master_ad <- haven::read_sas(here::here("data/SAS/created/master_ad_2018_0117.sas7bdat"))
```

Lots of the predictors are not present in the `hrs_training` and
`hrs_validation` data, but rather included in the `master_ad` data. So,
we add the predictors to the data sets.

For the training data, this is straightforward, since all training data
is from the ADAMS Wave A data set.

``` r
hrs_training <- left_join(
    hrs_training,
    master_ad %>% 
      select(
        HHID, 
        PN, 
        iadl = iadl5_A,
        adl = adl5_A,
        iqcode = iqcode_A,
        jorm_symptoms = jorm5symp_A,
        pr_memsc = pr_memsc1_A,
        iwercog = iwercog_A,
        immediate_word_recall = iword_A,
        delayed_word_recall = dword_A,
        serial7 = serial7_A,
        dates = dates_A,
        cactus = cact_A,
        scissors = scis_A,
        president = pres_A,
        vp = vp_A,
        count = ticscount1or2_A
      )
  ) %>% 
    mutate(dataset = 'Training')
```

    Joining with `by = join_by(HHID, PN)`

For the validation data, it is a bit more complicated. Here, we need to
pull the correct ADAMS wave for each row of the validation data.

``` r
hrs_validation <- hrs_validation %>% 
  left_join(
    master_ad %>% 
      select(
        HHID, 
        PN, 
        matches("^iadl5_[BCD]$"),
        matches("^adl5_[BCD]$"),
        matches("^iqcode_[BCD]$"),
        matches("^jorm5symp_[BCD]$"),
        matches("^pr_memsc1_[BCD]$"),
        matches("^iwercog_[BCD]$"),
        matches("^iword_[BCD]$"),
        matches("^dword_[BCD]$"),
        matches("^serial7_[BCD]$"),
        matches("^dates_[BCD]$"),
        matches("^cact_[BCD]$"),
        matches("^scis_[BCD]$"),
        matches("^pres_[BCD]$"),
        matches("^vp_[BCD]$"),
        matches("^ticscount1or2_[BCD]$")
      ) %>% 
      rename_with(
        .fn = \(x) str_remove(x, '_'),
        .cols = matches("^pr_memsc1_[BCD]$")
      ) %>% 
      pivot_longer(
        cols = matches("_[BCD]$"),
        names_to = c(".value", "ADAMSwave"),
        names_sep = "_",
      ) %>% 
      rename(
        iadl = iadl5,
        adl = adl5,
        jorm_symptoms = jorm5symp,
        pr_memsc = prmemsc1,
        immediate_word_recall = iword,
        delayed_word_recall = dword,
        cactus = cact,
        scissors = scis,
        president = pres,
        count = ticscount1or2
      ) %>% 
      mutate(
        ADAMSwave = str_to_lower(ADAMSwave)
      )
  ) %>% 
  mutate(
    dataset = 'Validation'
  )
```

    Joining with `by = join_by(HHID, PN, ADAMSwave)`

Finally, we recreate Table 1.

``` r
## We use sjmisc::add_rows to preserve column labels. (dplyr::bind_rows removes labels.)
table_1 <- sjmisc::add_rows(
  hrs_training,
  hrs_validation
) %>% 
  select(
    dement,
    hrs_age,
    proxy,
    female,
    edu_hurd,
    raceeth4,
    immediate_word_recall,
    delayed_word_recall,
    serial7,
    dates,
    cactus,
    scissors,
    president,
    vp,
    count,
    iwercog,
    pr_memsc,
    iqcode,
    jorm_symptoms,
    adl, 
    iadl,
    dataset
  ) %>% 
  mutate(
    ## Replace self-response for proxy that are 0 with NA
    immediate_word_recall = if_else(proxy == 0, immediate_word_recall, NA),
    delayed_word_recall = if_else(proxy == 0, delayed_word_recall, NA),
  ) %>% 
  gtsummary::tbl_summary(
    by = 'dataset',
    statistic = list(all_continuous() ~ "{mean} ({sd})", all_categorical() ~ "{n} ({p}%)"),
    type = list(
      adl = 'continuous',
      iadl = "continuous",
      jorm_symptoms = "continuous",
      pr_memsc = "continuous",
      serial7 = 'continuous',
      dates = 'continuous'
    ),
    digits = list(
      all_continuous() ~ 1
    )
  ) %>% 
  modify_header(
    label ~ "**Outcomes and Predictors**"
  ) %>% 
  modify_footnote(
    all_stat_cols() ~ NA
  ) %>% 
  modify_spanning_header(
    c(stat_1, stat_2) ~ "**Mean (SD) or N (%)**"
  ) %>% 
  modify_table_body(
    mutate,
    groupname_col = case_match(
      variable,
      'dement' ~ 'Dementia Outcomes',
      c("hrs_age", "proxy", "female", "edu_hurd", "raceeth4") ~ 'Demographics',
      c('immediate_word_recall', 'delayed_word_recall', 'serial7', 
        'dates', 'cactus', 'scissors', 'president', 'vp', 'count') ~ 'Cognition (self-response)',
      c("iwercog", "pr_memsc", "iqcode", "jorm_symptoms") ~ 'Cognition (proxy)',
      c('adl', 'iadl') ~ 'Physical functioning limitations'
    )
  ) %>% 
  modify_column_indent(
    columns = label,
    rows = row_type %in% 'label',
    indent = 4L
  ) %>% 
  modify_column_indent(
    columns = label,
    rows = !row_type %in% 'label',
    indent = 8L
  ) %>% 
  as_gt() %>%
  cols_width(
    label ~ px(550)
  ) %>% 
  tab_options(
    row_group.font.weight = "500",
    row_group.background.color = 'white'
  ) 
```

</details>

A few things to note about the table below:

- Some rows indicate that there are a number of “unknown” (or missing)
  values. For the variables in the “Cognition (self-response)” group,
  those who were evaluated by proxy are excluded. Therefore, unknown =
  number of proxy cases. For “Cognition (proxy)”, unknown = number of
  NOT proxy cases.
- There is a mistake in the label for the `delayed word recall`
  variable: this is in fact on a scale from 0 to 10, not 0 to 1.
- The proxy rated memory score is for some reason on a scale of 0 to 4,
  whereas in Table 1 of Gianattasio et al. (2019) it is on a scale from
  1 to 5. Simply add 1 to the means, and we see that they match.

<style>
tr.even {background-color: white;}
</style>

``` r
table_1
```

<div id="amkzepfarb" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#amkzepfarb table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#amkzepfarb thead, #amkzepfarb tbody, #amkzepfarb tfoot, #amkzepfarb tr, #amkzepfarb td, #amkzepfarb th {
  border-style: none;
}
&#10;#amkzepfarb p {
  margin: 0;
  padding: 0;
}
&#10;#amkzepfarb .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#amkzepfarb .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#amkzepfarb .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#amkzepfarb .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#amkzepfarb .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#amkzepfarb .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#amkzepfarb .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#amkzepfarb .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#amkzepfarb .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#amkzepfarb .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: 500;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#amkzepfarb .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: 500;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#amkzepfarb .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#amkzepfarb .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#amkzepfarb .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#amkzepfarb .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#amkzepfarb .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#amkzepfarb .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#amkzepfarb .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#amkzepfarb .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#amkzepfarb .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#amkzepfarb .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#amkzepfarb .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#amkzepfarb .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#amkzepfarb .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#amkzepfarb .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#amkzepfarb .gt_left {
  text-align: left;
}
&#10;#amkzepfarb .gt_center {
  text-align: center;
}
&#10;#amkzepfarb .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#amkzepfarb .gt_font_normal {
  font-weight: normal;
}
&#10;#amkzepfarb .gt_font_bold {
  font-weight: bold;
}
&#10;#amkzepfarb .gt_font_italic {
  font-style: italic;
}
&#10;#amkzepfarb .gt_super {
  font-size: 65%;
}
&#10;#amkzepfarb .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#amkzepfarb .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#amkzepfarb .gt_indent_1 {
  text-indent: 5px;
}
&#10;#amkzepfarb .gt_indent_2 {
  text-indent: 10px;
}
&#10;#amkzepfarb .gt_indent_3 {
  text-indent: 15px;
}
&#10;#amkzepfarb .gt_indent_4 {
  text-indent: 20px;
}
&#10;#amkzepfarb .gt_indent_5 {
  text-indent: 25px;
}
&#10;#amkzepfarb .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#amkzepfarb div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

<table class="gt_table" data-quarto-postprocess="true"
style="table-layout: fixed;" data-quarto-disable-processing="false"
data-quarto-bootstrap="false">
<thead>
<tr class="header gt_col_headings gt_spanner_row">
<th rowspan="2"
id="&lt;div data-qmd-base64=&quot;KipPdXRjb21lcyBhbmQgUHJlZGljdG9ycyoq&quot;&gt;&lt;div class=&#39;gt_from_md&#39;&gt;&lt;p&gt;&lt;strong&gt;Outcomes and Predictors&lt;/strong&gt;&lt;/p&gt;
&lt;/div&gt;&lt;/div&gt;"
class="gt_col_heading gt_columns_bottom_border gt_left"
data-quarto-table-cell-role="th" scope="col"><p><strong>Outcomes and
Predictors</strong></p></th>
<th colspan="2"
id="&lt;div data-qmd-base64=&quot;KipNZWFuIChTRCkgb3IgTiAoJSkqKg==&quot;&gt;&lt;div class=&#39;gt_from_md&#39;&gt;&lt;p&gt;&lt;strong&gt;Mean (SD) or N (%)&lt;/strong&gt;&lt;/p&gt;
&lt;/div&gt;&lt;/div&gt;"
class="gt_center gt_columns_top_border gt_column_spanner_outer"
data-quarto-table-cell-role="th" scope="colgroup"><span
class="gt_column_spanner"></span>
<p><strong>Mean (SD) or N (%)</strong></p>
</span></th>
</tr>
<tr class="odd gt_col_headings">
<th
id="&lt;div data-qmd-base64=&quot;KipUcmFpbmluZyoqICAKTiA9IDc2MA==&quot;&gt;&lt;div class=&#39;gt_from_md&#39;&gt;&lt;p&gt;&lt;strong&gt;Training&lt;/strong&gt;&lt;br /&gt;
N = 760&lt;/p&gt;
&lt;/div&gt;&lt;/div&gt;"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th"
scope="col"><p><strong>Training</strong><br />
N = 760</p></th>
<th
id="&lt;div data-qmd-base64=&quot;KipWYWxpZGF0aW9uKiogIApOID0gNTE1&quot;&gt;&lt;div class=&#39;gt_from_md&#39;&gt;&lt;p&gt;&lt;strong&gt;Validation&lt;/strong&gt;&lt;br /&gt;
N = 515&lt;/p&gt;
&lt;/div&gt;&lt;/div&gt;"
class="gt_col_heading gt_columns_bottom_border gt_center"
data-quarto-table-cell-role="th"
scope="col"><p><strong>Validation</strong><br />
N = 515</p></th>
</tr>
</thead>
<tbody class="gt_table_body">
<tr class="odd gt_group_heading_row">
<td colspan="3" id="Dementia Outcomes" class="gt_group_heading"
data-quarto-table-cell-role="th" scope="colgroup">Dementia Outcomes</td>
</tr>
<tr class="even gt_row_group_first">
<td class="gt_row gt_left"
headers="Dementia Outcomes  label">    Dementia ascertainment in wave
A</td>
<td class="gt_row gt_center" headers="Dementia Outcomes  stat_1">258
(34%)</td>
<td class="gt_row gt_center" headers="Dementia Outcomes  stat_2">71
(14%)</td>
</tr>
<tr class="odd gt_group_heading_row">
<td colspan="3" id="Demographics" class="gt_group_heading"
data-quarto-table-cell-role="th" scope="colgroup">Demographics</td>
</tr>
<tr class="even gt_row_group_first">
<td class="gt_row gt_left" headers="Demographics  label">    age at HRS
interview: for wave A dementia prediction</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">80.3
(7.0)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">81.2
(5.8)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">    proxy
indicator for closest HRS interview completed prior to wave A</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">165
(22%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">30
(5.8%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left" headers="Demographics  label">    1=female,
0=male</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">452
(59%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">270
(52%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">    Hurd educ
classification - 3 level, &lt;HS ref</td>
<td class="gt_row gt_center" headers="Demographics  stat_1"><br />
</td>
<td class="gt_row gt_center" headers="Demographics  stat_2"><br />
</td>
</tr>
<tr class="even">
<td class="gt_row gt_left" headers="Demographics  label">        0</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">369
(49%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">215
(42%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">        1</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">298
(39%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">222
(43%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left" headers="Demographics  label">        2</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">93
(12%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">78
(15%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">    0=NH white,
1=NH black, 2=Hispanic, 3=NH other</td>
<td class="gt_row gt_center" headers="Demographics  stat_1"><br />
</td>
<td class="gt_row gt_center" headers="Demographics  stat_2"><br />
</td>
</tr>
<tr class="even">
<td class="gt_row gt_left" headers="Demographics  label">        0</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">526
(69%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">369
(72%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">        1</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">140
(18%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">97
(19%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left" headers="Demographics  label">        2</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">76
(10%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">35
(6.8%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Demographics  label">        3</td>
<td class="gt_row gt_center" headers="Demographics  stat_1">18
(2.4%)</td>
<td class="gt_row gt_center" headers="Demographics  stat_2">14
(2.7%)</td>
</tr>
<tr class="even gt_group_heading_row">
<td colspan="3" id="Cognition (self-response)" class="gt_group_heading"
data-quarto-table-cell-role="th" scope="colgroup">Cognition
(self-response)</td>
</tr>
<tr class="odd gt_row_group_first">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    immediate word recall
(0-10): for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">3.9 (1.8)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">4.4 (1.6)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    delayed word recall
(0-1): for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">2.6 (2.1)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">3.0 (1.9)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS serial7: for wave A
dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">2.4 (1.9)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">2.8 (1.9)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS dates score (0-4):
for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">3.4 (1.0)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">3.6 (0.7)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS cactus: for wave A
dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">451 (76%)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">404 (83%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS scissors: for wave A
dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">587 (99%)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">478 (99%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS president: for wave
A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">518 (87%)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">454 (94%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS vice president: for
wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">319 (54%)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">318 (66%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">    TICS backward count
(1=correct attempt 1 or attempt 2): for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">503 (85%)</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">430 (89%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (self-response)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_1">165</td>
<td class="gt_row gt_center"
headers="Cognition (self-response)  stat_2">30</td>
</tr>
<tr class="odd gt_group_heading_row">
<td colspan="3" id="Cognition (proxy)" class="gt_group_heading"
data-quarto-table-cell-role="th" scope="colgroup">Cognition (proxy)</td>
</tr>
<tr class="even gt_row_group_first">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">    inteviewer assessment of cogn
impairment (0-2): for wave A dementia prediction run</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1"><br />
</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2"><br />
</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        0</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">28
(17%)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">13
(43%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        1</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">25
(15%)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">8
(27%)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        2</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">112
(68%)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">9
(30%)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_1">595</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_2">485</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Cognition (proxy)  label">    proxy
memory score ctrd at 1 (0-4): for wave A dementia prediction run</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">3.3
(1.0)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">2.5
(1.0)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_1">595</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_2">485</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">    IQCODE: for wave A dementia
prediction run</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">4.2
(0.7)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">3.4
(0.5)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_1">595</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_2">485</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left" headers="Cognition (proxy)  label">    Jorm
symptoms out of 5: for wave A dementia prediction run</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_1">1.8
(1.5)</td>
<td class="gt_row gt_center" headers="Cognition (proxy)  stat_2">0.6
(1.0)</td>
</tr>
<tr class="even">
<td class="gt_row gt_left"
headers="Cognition (proxy)  label">        Unknown</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_1">595</td>
<td class="gt_row gt_center"
headers="Cognition (proxy)  stat_2">485</td>
</tr>
<tr class="odd gt_group_heading_row">
<td colspan="3" id="Physical functioning limitations"
class="gt_group_heading" data-quarto-table-cell-role="th"
scope="colgroup">Physical functioning limitations</td>
</tr>
<tr class="even gt_row_group_first">
<td class="gt_row gt_left"
headers="Physical functioning limitations  label">    total ADL
limitations out of 5: for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Physical functioning limitations  stat_1">1.0 (1.5)</td>
<td class="gt_row gt_center"
headers="Physical functioning limitations  stat_2">0.6 (1.1)</td>
</tr>
<tr class="odd">
<td class="gt_row gt_left"
headers="Physical functioning limitations  label">    total IADL
limitations out of 5: for wave A dementia prediction</td>
<td class="gt_row gt_center"
headers="Physical functioning limitations  stat_1">1.2 (1.8)</td>
<td class="gt_row gt_center"
headers="Physical functioning limitations  stat_2">0.5 (1.1)</td>
</tr>
</tbody>
</table>

</div>

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
