#!/bin/bash

#
# * Derrek Hibar  - derrek.hibar@ini.usc.edu
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * Modified by Chi-Hua Chen - chc101@ucsd.edu
# * ENIGMA 2014.
# Last edit 2016 Jan 15, by chc

##################################
######## USER INPUTS #############
##################################

run_directory=/ENIGMA/GCLUSTGWAS/SCRIPTS/enigma_backend_GCLUST                  # Directory where all the enigma association scripts are stored
Rbin=/usr/bin/R                 								 # Full path to R binary


csvFILE_1=/ENIGMA/GCLUSTGWAS/gclust_area.csv          # Path to the surf area csv file
csvFILE_2=/ENIGMA/GCLUSTGWAS/gclust_thickness.csv          # Path to the thickness csv file
csvFOLDER=/ENIGMA/GCLUSTGWAS/E3     									 # Directory to write out the updated and filtered csv file (this folder will be created for you)
																		 ## new csv file will be named "${csvFOLDER}/CorticalMeasuresENIGMA_ALL_Avg.csv" and "${csvFOLDER}/combinedROItable_eCORTEX4GWAS.csv"

## please indicate the file where your meta data is stored so that we can merge in relavent covariates to the ENIGMA phenotype files
TableFile=/ENIGMA/GCLUSTGWAS/Covariates.csv
## what is the column name where the subject IDs are listed to match subject-by-subject with the ENIGMA files?
TableSubjectID_column="SubjID"

## How many covariates will you be using (note, at a minimum we would require 2 or 3 -- age and sex and disease if dataset consists of patients and controls, and any additional site-specific variables, please contact us with questions!)
Ncov=2
## in your table file, what are the column headers for the covariates you would like to include? Make sure to separate them here with a semi-colon and no space!
## Remember that datasets with patients and controls (and those with patients-only) need to include an AffectionStatus covariate with patients = 1 and contorls = 0
covariates="Age;Sex"

######################################
######## END USER INPUTS #############
######################################



#######################################

if [ ! -d ${csvFOLDER} ]; then
mkdir ${csvFOLDER}
fi

######## Step 1, combine ROI files and average across L and R #############
${Rbin} --no-save --slave --args ${csvFILE_1} ${csvFILE_2} ${csvFOLDER} <  ${run_directory}/e3_functions.R

######## Step 2, merge phenotype ROIs and covariates into the same file #############
PhenoFile=${csvFOLDER}/CorticalMeasures_ENIGMA_ALL_Avg.csv
PhenoSubjectID_column="SubjID"
outTable=${csvFOLDER}/combinedROItable_eCORTEX4GWAS.csv

${Rbin} --no-save --slave --args $TableFile $TableSubjectID_column $PhenoFile $PhenoSubjectID_column $Ncov $covariates $outTable <  ${run_directory}/add_Info.R
