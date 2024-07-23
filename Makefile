# Define lists of directories that should be created in data/HRS-unzips
adamsDirs := data/HRS-unzips/adams1a data/HRS-unzips/adams1b data/HRS-unzips/adams1trk
hDirs := data/HRS-unzips/h98 data/HRS-unzips/h00 data/HRS-unzips/h02 data/HRS-unzips/h04 data/HRS-unzips/h06 data/HRS-unzips/h08 data/HRS-unzips/h10

all: unzip_all data/SAS/rand/formats.sas7bcat update_all_sas run_all_sas

update_all_sas: data/HRS-unzips/adams1a/new_sas data/HRS-unzips/adams1b/new_sas data/HRS-unzips/adams1trk/new_sas \
	data/HRS-unzips/h98/new_sas \
	data/HRS-unzips/h00/new_sas \
	data/HRS-unzips/h02/new_sas \
	data/HRS-unzips/h04/new_sas \
	data/HRS-unzips/h06/new_sas \
	data/HRS-unzips/h08/new_sas \
	data/HRS-unzips/h10/new_sas

run_all_sas: data/SAS/adams1a data/SAS/adams1b data/SAS/adams1trk data/SAS/HRS

# Check if specific zip is present
data/HRS-zips/%.zip: 
	bash scripts/bash/check_requirements.sh -f $@

# Check if all zips are present
check_all_zips: 
	bash scripts/bash/check_requirements.sh

# Unzip everything
unzip_all: check_all_zips
	$(MAKE) $(adamsDirs)
	$(MAKE) $(hDirs)
	$(MAKE) data/SAS/rand

# Unzip ADAMS zip-files
data/HRS-unzips/adams1%: data/HRS-zips/adams1%.zip
ifdef password
	bash scripts/bash/unzip_adams_files.sh -f data/HRS-zips/`basename $@`.zip -p $(password)
else
	$(error Password not set!!!)
endif

# Unzip h* zip-files
data/HRS-unzips/h%: data/HRS-zips/h%da.zip data/HRS-zips/h%sas.zip
	bash scripts/bash/unzip_h_files.sh -f data/HRS-zips/`basename $@`

# Unzip RAND zip-files
data/SAS/rand: data/HRS-zips/randhrsp_archive_SAS.zip
	bash scripts/bash/unzip_rand.sh

# Create updated SAS files for ADAMS
data/HRS-unzips/adams1%/new_sas: # data/HRS-unzips/adams1
	bash scripts/bash/update_adams_sas_files.sh -d $(abspath $@)

# Create formats for RAND file
data/SAS/rand/formats.sas7bcat: data/SAS/rand
	bash scripts/bash/create_rand_formats.sh -d $(dir $(abspath $@))

# Create updated SAS files for h%%
data/HRS-unzips/h%/new_sas: data/HRS-unzips/h%
	bash scripts/bash/update_hrs_sas_files.sh -d $(abspath $@)

# Run updated SAS files to create new sas datasets
data/SAS/HRS:
	bash scripts/bash/run_hrs_sas_file.sh
data/SAS/adams1%: 
	bash scripts/bash/run_adams_sas.sh $(notdir $@)

# Download AD Algorithm Comparison repo and checkout commit known to work (probably not needed, but in case orig author makes future chances)
AD_algorithm_comparison:
	git clone git@github.com:powerepilab/AD_algorithm_comparison.git AD_algorithm_comparison
	cd AD_algorithm_comparison; git reset --hard 1338e71

# Create updated_AD_algorithm_comparisons
updated_AD_algorithm_comparison/%.sas: AD_algorithm_comparison/*
	bash scripts/bash/update_AD_algorithm_comparison_sas_files.sh

## Create HRS training and validation data sets
# First, 1a
data/SAS/created/master_ad_2018_0117.sas7bdat: updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas
	sas updated_AD_algorithm_comparison/1a_extract_self_response_variables.sas

# Second, 1b




# Clean/reset. I.e. remove everything created by this Makefile
clean:
	rm -rf data/{SAS,HRS-unzips}
	rm -rf logs
	rm -rf AD_algorithm_comparison
	rm -rf updated_AD_algorithm_comparison

