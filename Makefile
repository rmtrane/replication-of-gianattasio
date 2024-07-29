# all: unzip_all \
# data/SAS/rand/formats.sas7bcat \
# update_all_sas \
# run_all_sas \
# data/SAS/HRS/hurdprobabilities_wide.sas7bdat \
# AD_algorithm_comparison \
# updated_AD_algorithm_comparison \
# data/SAS/created/HRSt_2018_0302.sas7bdat

# update_all_sas: data/HRS-unzips/adams1a/new_sas data/HRS-unzips/adams1b/new_sas data/HRS-unzips/adams1trk/new_sas \
# data/HRS-unzips/a95/new_sas \
# data/HRS-unzips/h96/new_sas \
# data/HRS-unzips/h98/new_sas \
# data/HRS-unzips/h00/new_sas \
# data/HRS-unzips/h02/new_sas \
# data/HRS-unzips/h04/new_sas \
# data/HRS-unzips/h06/new_sas \
# data/HRS-unzips/h08/new_sas \
# data/HRS-unzips/h10/new_sas

# run_all_sas: data/SAS/adams1a data/SAS/adams1b data/SAS/adams1trk data/SAS/HRS

###############
## Unzip Files
###############

# Define lists of directories that should be created in data/HRS-unzips
adamsDirs := data/HRS-unzips/adams1a data/HRS-unzips/adams1b data/HRS-unzips/adams1trk
hDirs := data/HRS-unzips/a95 data/HRS-unzips/h96 data/HRS-unzips/h98 data/HRS-unzips/h00 data/HRS-unzips/h02 data/HRS-unzips/h04 data/HRS-unzips/h06 data/HRS-unzips/h08 data/HRS-unzips/h10

# Check if specific zip is present
data/HRS-zips/%.zip: 
	@bash scripts/bash/check_requirements.sh -f $@

# Check if all zips are present
check_all_zips: 
	@bash scripts/bash/check_requirements.sh

# Unzip everything
unzip_all: check_all_zips
	@echo "ADAMS"
	@$(MAKE) $(addsuffix /touch, $(adamsDirs))
	@echo "HRS"
	@$(MAKE) $(addsuffix /touch, $(hDirs))
	@echo "RAND"
	@$(MAKE) data/SAS/rand/rndhrs_p.sas7bdat
	@echo "HURD"
	@$(MAKE) data/SAS/hurd/hurdprobabilities_wide.sas7bdat

# Unzip hurd probabilities
data/SAS/hurd/hurdprobabilities_wide.sas7bdat: data/HRS-zips/DementiaPredictedProbabilities.zip
	@mkdir -p data/SAS/hurd
	@unzip -q data/HRS-zips/DementiaPredictedProbabilities.zip -d data/SAS/hurd

# Unzip ADAMS zip-files
data/HRS-unzips/adams1%/touch: data/HRS-zips/adams1%.zip
ifdef password
	@bash scripts/bash/unzip_files.sh -f $< -p $(password)
	@touch $@
else
	$(error Password not set!!!)
endif

# Extra targets for .sas and .da files
data/HRS-unzips/adams1a/sas/%.sas: data/HRS-zips/adams1a.zip
	@$(MAKE) data/HRS-unzips/adams1a/touch

data/HRS-unzips/adams1b/sas/%.sas: data/HRS-zips/adams1b.zip
	@$(MAKE) data/HRS-unzips/adams1b/touch

data/HRS-unzips/adams1a/da/%.da: data/HRS-zips/adams1a.zip
	@$(MAKE) data/HRS-unzips/adams1a/touch

data/HRS-unzips/adams1b/da/%.da: data/HRS-zips/adams1b.zip
	@$(MAKE) data/HRS-unzips/adams1b/touch


# Unzip h* zip-files
data/HRS-unzips/h%/touch: data/HRS-zips/h%da.zip data/HRS-zips/h%sas.zip
	@bash scripts/bash/unzip_files.sh -f $(subst unzips,zips,$(patsubst %/,%,$(dir $@))) && touch $@  # data/HRS-zips/`basename $@`
data/HRS-unzips/a%/touch: data/HRS-zips/a%da.zip data/HRS-zips/a%sas.zip
	@bash scripts/bash/unzip_files.sh -f $(subst unzips,zips,$(patsubst %/,%,$(dir $@))) && touch $@  # data/HRS-zips/`basename $@`	

# Unzip RAND zip-files to get rndhrs_p.sas7bdat and create data/SAS/HRS/hurdprobabilities_wide.sas7bdat
data/SAS/rand/rndhrs_p.sas7bdat: data/HRS-zips/randhrsp_archive_SAS.zip
	@mkdir -p data/SAS
	@unzip -q data/HRS-zips/randhrsp_archive_SAS.zip -d data/SAS/rand && touch data/SAS/rand/touch

data/SAS/HRS/hurdprobabilities_wide.sas7bdat: data/SAS/hurd/hurdprobabilities_wide.sas7bdat
	@mkdir -p data/SAS/created
	@Rscript -e "library(tidyr); haven::read_sas('data/SAS/hurd/pdem_withvarnames.sas7bdat') %>% pivot_wider(names_from = prediction_year, values_from = prob_dementia, names_prefix = 'hurd_prob_') %>% readr::write_csv('data/SAS/created/hurdprobabilities_wide.csv', na = '.')"


##################
## Update SAS scripts with correct paths
##################

# Define list with files that should be created in data/HRS-unzips/adams1{a,b}/new_sas
#adams1a_new_sas := ADAMS1AB_R.sas \
ADAMS1AC_R.sas \
ADAMS1AD_R.sas \
ADAMS1AE_D.sas \
ADAMS1AF_R.sas \
ADAMS1AF_CH.sas \
ADAMS1AF_SB.sas \
ADAMS1AG_R.sas \
ADAMS1AH_R.sas \
ADAMS1AH_C.sas \
ADAMS1AJ_R.sas \
ADAMS1AM_R.sas \
ADAMS1AN_R.sas

# Create updated SAS files for ADAMS
data/HRS-unzips/adams1a/new_sas/%.sas: data/HRS-unzips/adams1a/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/adams1b/new_sas/%.sas: data/HRS-unzips/adams1b/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/adams1trk/new_sas/%.sas: data/HRS-unzips/adams1trk/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)

# Create updated SAS files for HRS
data/HRS-unzips/a95/new_sas/%.sas: data/HRS-unzips/a95/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h96/new_sas/%.sas: data/HRS-unzips/h96/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h98/new_sas/%.sas: data/HRS-unzips/h98/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h00/new_sas/%.sas: data/HRS-unzips/h00/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h02/new_sas/%.sas: data/HRS-unzips/h02/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h04/new_sas/%.sas: data/HRS-unzips/h04/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h06/new_sas/%.sas: data/HRS-unzips/h06/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h08/new_sas/%.sas: data/HRS-unzips/h08/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)
data/HRS-unzips/h10/new_sas/%.sas: data/HRS-unzips/h10/touch
	@bash scripts/bash/update_sas_file.sh -f $(subst /new_sas/,/sas/,$@)

# Create new_sas for all sas files
update_all_sas:
	@$(MAKE) $(subst /sas/,/new_sas/,$(wildcard data/HRS-unzips/*/sas/*))

# Create formats for RAND file
data/SAS/rand/formats.sas7bcat: data/SAS/rand/touch
	@bash scripts/bash/create_rand_formats.sh -d $(dir $(abspath $@))

# List of all SAS files that should be run
allHRSSASfiles := $(notdir $(wildcard data/HRS-unzips/h*/new_sas/*.sas data/HRS-unzips/a95/new_sas/*.sas))

$(addsuffix 7bdat,$(addprefix data/SAS/HRS/,$(allHRSSASfiles))) : # data/SAS/HRS/%.sas7bdat : $(wildcard data/HRS-unzips/*/new_sas/%.sas)
	@$(MAKE) `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"`
	@mkdir -p logs/HRS
	@sas `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"` -log logs/HRS/

allADAMSSASfiles := $(notdir $(wildcard data/HRS-unzips/adams*/new_sas/*.sas))

$(addsuffix 7bdat,$(addprefix data/SAS/ADAMS/,$(allADAMSSASfiles))) : # data/SAS/HRS/%.sas7bdat : $(wildcard data/HRS-unzips/*/new_sas/%.sas)
	@$(MAKE) `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"`
	@mkdir -p logs/ADAMS
	@sas `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"` -log logs/ADAMS/

run_all_sas:
	@$(MAKE) $(addsuffix 7bdat,$(addprefix data/SAS/ADAMS/,$(allADAMSSASfiles)) $(addprefix data/SAS/HRS/,$(allHRSSASfiles)))

# Run updated SAS files to create new sas datasets
# data/SAS/HRS/%.sas7bdat: $(wildcard */new_sas/%.sas)
#	@echo $@
#	@echo $<
# @mkdir -p data/SAS/HRS
# @mkdir -p logs/HRS
# @sas data/HRS-unzips/%

# Download AD Algorithm Comparison repo and checkout commit known to work (probably not needed, but in case orig author makes future chances)
AD_algorithm_comparison: 
	git clone git@github.com:powerepilab/AD_algorithm_comparison.git AD_algorithm_comparison
	cd AD_algorithm_comparison; git reset --hard 1338e71

# Create updated_AD_algorithm_comparison (one file at a time)
updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas updated_AD_algorithm_comparison/2_create_lags_etc.sas updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas: AD_algorithm_comparison
	bash scripts/bash/update_AD_algorithm_comparison_sas_files.sh
	bash scripts/bash/insert_proc_hurd_in_3_create_training_and_validation_datasets.sh

# Create all updated_AD_algorithm_comparison
updated_AD_algorithm_comparison: AD_algorithm_comparison
	bash scripts/bash/update_AD_algorithm_comparison_sas_files.sh
	bash scripts/bash/insert_proc_hurd_in_3_create_training_and_validation_datasets.sh

## Create HRS training and validation data sets

# First, run 1b (which in turn calls 1a)
data/SAS/created/master_2018_0117.sas7bdat: updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas
	mkdir -p logs/updated_AD_algorithm_comparison
	sas updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas -log logs/updated_AD_algorithm_comparison/ # 1a_extract_self_response_variables.sas

# Second, run 2
data/SAS/created/master_ad_2018_0117.sas7bdat: data/SAS/created/master_2018_0117.sas7bdat updated_AD_algorithm_comparison/2_create_lags_etc.sas 
	sas updated_AD_algorithm_comparison/2_create_lags_etc.sas -log logs/updated_AD_algorithm_comparison/

# Third, run 3
data/SAS/created/master_adpred_wide_2018_0302.sas7bdat data/SAS/created/HRSt_2018_0302.sas7bdat data/SAS/created/HRSv_2018_0302.sas7bdat data/SAS/created/commsampfinal_key.sas7bdat: data/SAS/HRS/hurdprobabilities_wide.sas7bdat data/SAS/created/master_ad_2018_0117.sas7bdat
	sas updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas -log logs/updated_AD_algorithm_comparison/

# Clean/reset. I.e. remove everything created by this Makefile
clean:
	@if [ -d data/SAS ]; then echo "Removing data/SAS"; rm -r data/SAS; fi
	@if [ -d data/HRS-unzips ]; then echo "Removing data/HRS-unzips"; rm -r data/HRS-unzips; fi
	@if [ -d logs ]; then echo "Removing logs"; rm -r logs; fi
	@if [ -d AD_algorithm_comparison ]; then echo "Removing AD_algorithm_comparison"; rm -r AD_algorithm_comparison; fi
	@if [ -d updated_AD_algorithm_comparison ]; then echo "Removing updated_AD_algorithm_comparison"; rm -r updated_AD_algorithm_comparison; fi

# Remove log,pdf,lst files
	@find . -type f \( -iname "*.log" -o -iname "*.pdf" -o -iname "*.lst" \) | while read f; do rm $f; done

