all:
	@echo "##########################################################"
	@echo "## Unzip all .zip files into data/HRS-unzips/           ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) unzip_all
	@echo ""
	@echo "##########################################################"
	@echo "## Update all HRS and ADAMS SAS files                   ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) --silent .update_all_sas
	@echo ""
	@echo "##########################################################"
	@echo "## Run all SAS                                          ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) .run_all_sas
	@echo ""
	@echo "##########################################################"
	@echo "## Download AD_algorithm_comparison repo                ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) AD_algorithm_comparison/touch
	@echo ""
	@echo "##########################################################"
	@echo "## Create updated_AD_algorithm_comparison               ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) updated_AD_algorithm_comparison/touch
	@echo ""
	@echo "##########################################################"
	@echo "## Run SAS files 1a and 1b from AD_algorithm_comparison ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) data/SAS/created/master_2018_0117.sas7bdat
	@$(MAKE) data/SAS/created/master_ad_2018_0117.sas7bdat
	@echo ""
	@echo "##########################################################"
	@echo "## Run SAS file 2 from AD_algorithm_comparison          ##"
	@echo "##########################################################"
	@echo ""
	@$(MAKE) data/SAS/created/hrst_2018_0302.sas7bdat

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
check_all_zips: $(subst unzips,zips,$(addsuffix .zip,$(adamsDirs)) $(addsuffix da.zip,$(hDirs)) $(addsuffix sas.zip,$(hDirs))) data/HRS-zips/randhrsp_archive_SAS.zip data/HRS-zips/DementiaPredictedProbabilities.zip

# Unzip everything
unzip_all: check_all_zips
	@echo "ADAMS"
	@$(MAKE) --silent $(addsuffix /touch, $(adamsDirs))
	@echo "HRS"
	@$(MAKE) --silent $(addsuffix /touch, $(hDirs))
	@echo "RAND"
	@$(MAKE) --silent data/SAS/rand/touch
	@echo "HURD"
	@$(MAKE) --silent data/SAS/hurd/touch # hurdprobabilities_wide.sas7bdat

# Unzip hurd probabilities
data/SAS/hurd/touch: data/HRS-zips/DementiaPredictedProbabilities.zip
	@mkdir -p data/SAS/hurd
	@unzip -q data/HRS-zips/DementiaPredictedProbabilities.zip -d data/SAS/hurd && touch data/SAS/hurd/touch

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
data/SAS/rand/touch: data/HRS-zips/randhrsp_archive_SAS.zip
	@mkdir -p data/SAS
	@unzip -q data/HRS-zips/randhrsp_archive_SAS.zip -d data/SAS/rand && touch data/SAS/rand/touch

data/SAS/HRS/hurdprobabilities_wide.sas7bdat: data/SAS/hurd/touch #hurdprobabilities_wide.sas7bdat
	@mkdir -p data/SAS/created
	@Rscript -e "library(tidyr); haven::read_sas('data/SAS/hurd/pdem_withvarnames.sas7bdat') %>% pivot_wider(names_from = prediction_year, values_from = prob_dementia, names_prefix = 'hurd_prob_') %>% readr::write_csv('data/SAS/created/hurdprobabilities_wide.csv', na = '.')"


##################
## Update SAS scripts with correct paths
##################

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
.update_all_sas:
	@$(MAKE) $(subst /sas/,/new_sas/,$(wildcard data/HRS-unzips/*/sas/*))
	@touch .update_all_sas

# Create formats for RAND file
data/SAS/rand/formats.sas7bcat: data/SAS/rand/touch
	@bash scripts/bash/create_rand_formats.sh -d $(dir $(abspath $@))

# List of all HRS SAS files that should be run
allHRSSASfiles := $(notdir $(wildcard data/HRS-unzips/h*/new_sas/*.sas data/HRS-unzips/a95/new_sas/*.sas))

$(addsuffix 7bdat,$(addprefix data/SAS/HRS/,$(allHRSSASfiles))):
	@$(MAKE) `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"`
	@mkdir -p {logs,data/SAS}/HRS
	@sas `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"` -log logs/HRS/

# List of all ADAMS SAS files that should be run
allADAMSSASfiles := $(notdir $(wildcard data/HRS-unzips/adams*/new_sas/*.sas))

$(addsuffix 7bdat,$(addprefix data/SAS/ADAMS/,$(allADAMSSASfiles))):
	@$(MAKE) `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"`
	@mkdir -p {logs,data/SAS}/ADAMS
	@sas `find data/HRS-unzips/*/new_sas -type f -iname "$(basename $(notdir $@)).sas"` -log logs/ADAMS/

# Target to run all
.run_all_sas:
	@echo "Run all ADAMS sas files..."
	@$(MAKE) $(addsuffix 7bdat,$(addprefix data/SAS/ADAMS/,$(allADAMSSASfiles)))
	@echo "Run all HRS sas files..."
	@$(MAKE) $(addsuffix 7bdat,$(addprefix data/SAS/HRS/,$(allHRSSASfiles)))
	@touch .run_all_sas

####################
## AD Algorithm Comparison
####################

# Download AD Algorithm Comparison repo and checkout commit known to work (probably not needed, but in case orig author makes future chances)
AD_algorithm_comparison/touch: 
	git clone git@github.com:powerepilab/AD_algorithm_comparison.git AD_algorithm_comparison
	cd AD_algorithm_comparison; git reset --hard 1338e71 && touch touch

# Create updated_AD_algorithm_comparison (making any target will create all targets)
updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas updated_AD_algorithm_comparison/2_create_lags_etc.sas updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas: AD_algorithm_comparison/touch
	@echo "Updating AD_algorithm_comparison..."
	@bash scripts/bash/update_AD_algorithm_comparison_sas_files.sh
	@bash scripts/bash/insert_proc_hurd_in_3_create_training_and_validation_datasets.sh
	@touch updated_AD_algorithm_comparison/touch

# Create all updated_AD_algorithm_comparison
updated_AD_algorithm_comparison/touch: AD_algorithm_comparison/touch
	@echo "Updating AD_algorithm_comparison..."
	@bash scripts/bash/update_AD_algorithm_comparison_sas_files.sh
	@bash scripts/bash/insert_proc_hurd_in_3_create_training_and_validation_datasets.sh
	@touch updated_AD_algorithm_comparison/touch

####################
## Create HRS training and validation data sets
####################

# First, run 1b (which in turn calls 1a)
data/SAS/created/master_2018_0117.sas7bdat: updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas data/SAS/rand/formats.sas7bcat .run_all_sas
	mkdir -p logs/updated_AD_algorithm_comparison
	sas updated_AD_algorithm_comparison/1b_extract_proxy_variables.sas -log logs/updated_AD_algorithm_comparison/

# Second, run 2
data/SAS/created/master_ad_2018_0117.sas7bdat: data/SAS/created/master_2018_0117.sas7bdat updated_AD_algorithm_comparison/2_create_lags_etc.sas 
	sas updated_AD_algorithm_comparison/2_create_lags_etc.sas -log logs/updated_AD_algorithm_comparison/

# Third, run 3
data/SAS/created/master_adpred_wide_2018_0302.sas7bdat data/SAS/created/hrst_2018_0302.sas7bdat data/SAS/created/hrsv_2018_0302.sas7bdat data/SAS/created/commsampfinal_key.sas7bdat: data/SAS/HRS/hurdprobabilities_wide.sas7bdat data/SAS/created/master_ad_2018_0117.sas7bdat
	sas updated_AD_algorithm_comparison/3_create_training_and_validation_datasets.sas -log logs/updated_AD_algorithm_comparison/


####################
## Clean
####################

# Clean/reset. I.e. remove everything created by this Makefile
clean:
	@if [ -d data/SAS ]; then echo "Removing data/SAS"; rm -r data/SAS; fi
	@if [ -d data/HRS-unzips ]; then echo "Removing data/HRS-unzips"; rm -r data/HRS-unzips; fi
	@if [ -d logs ]; then echo "Removing logs"; rm -r logs; fi
	@if [ -d AD_algorithm_comparison ]; then echo "Removing AD_algorithm_comparison"; rm -r AD_algorithm_comparison; fi
	@if [ -d updated_AD_algorithm_comparison ]; then echo "Removing updated_AD_algorithm_comparison"; rm -r updated_AD_algorithm_comparison; fi
	@find . -type f \( -iname "*.log" -o -iname "*.pdf" -o -iname "*.lst" \) | while read f; do rm $f; done
