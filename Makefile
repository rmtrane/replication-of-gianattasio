# Define lists of directories that should be created in data/HRS-unzips
adamsDirs := data/HRS-unzips/adams1a data/HRS-unzips/adams1b data/HRS-unzips/adams1trk
hDirs := data/HRS-unzips/h98 data/HRS-unzips/h00 data/HRS-unzips/h02 data/HRS-unzips/h04 data/HRS-unzips/h06 data/HRS-unzips/h08 data/HRS-unzips/h10

all: unzip_all $(adamsDirs)/new_sas data/HRS-unzips/rand/formats.sas7bcat $(hDirs)/

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
	$(MAKE) data/HRS-unzips/rand

# Unzip ADAMS zip-files
data/HRS-unzips/adams1%: data/HRS-zips/adams1%.zip
ifdef password
	bash scripts/bash/unzip_adams_files.sh -f data/HRS-zips/`basename $@`.zip -p $(password)
else
	@echo "Password not set"
endif

# Unzip h* zip-files
data/HRS-unzips/h%: data/HRS-zips/h%da.zip data/HRS-zips/h%sas.zip
	bash scripts/bash/unzip_h_files.sh -f data/HRS-zips/`basename $@`

# Unzip RAND zip-files
data/SAS/rand: data/HRS-zips/randhrsp_archive_SAS.zip
	bash scripts/bash/unzip_rand.sh

# Create updated SAS files for ADAMS
data/HRS-unzips/adams1%/new_sas: # data/HRS-unzips/adams1
	bash scripts/bash/update_adams_sas_files.sh -d $@

# Create formats for RAND file
data/SAS/rand/formats.sas7bcat: data/SAS/rand
	bash scripts/bash/create_rand_formats.sh -d $(dir $(abspath $@))

# Create updated SAS files for h%%
data/HRS-unzips/h%/new_sas: data/HRS-unzips/h%
	bash scripts/bash/update_hrs_sas_files.sh -d $@

# Run updated SAS files to create new sas datasets
data/SAS/HRS/%.sas7bdat: 
	bash scripts/bash/run_HRS_sas_file.sh -o $(notdir $@)

data/SAS/adams1%: 
	bash scripts/bash/run_adams_sas.sh $(notdir $@)


# Clean/reset. I.e. remove everything created by this Makefile
clean:
	rm -rf data/{SAS,HRS-unzips}


