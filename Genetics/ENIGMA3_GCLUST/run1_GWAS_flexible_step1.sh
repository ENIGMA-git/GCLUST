#!/bin/bash

#
# * Derrek Hibar - derrek.hibar@ini.usc.edu
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * Modified by Chi-Hua Chen - chc101@ucsd.edu
# * ENIGMA_DTI 2014.
# Last edit 2016 Jan 15, by chc

##################################
######## USER INPUTS #############
##################################

run_directory=/ENIGMA/GCLUSTGWAS/SCRIPTS/enigma_backend_GCLUST      							   # Directory where all the enigma association scripts are stored
Rbin=/usr/bin/R 									 							   # Full path to R binary

csvFILE=/ENIGMA/GCLUSTGWAS/HM3mds2R.mds.csv   				 							   #  Path to your HM3mds2Rmds.csv file -- has 4 MDS components to use as covariates (output from the MDS Analysis Protocol)

combinedROItableFILE=/ENIGMA/GCLUSTGWAS/E3/E3_out/combinedROItable_eCORTEX4GWAS.csv               #  Path to the csv file where your phenotypes and covariates are stored after running ./run0_E3_GWAS_format.sh

#
# Please give some information about the covariate coding you used:
#
ageColumnHeader='Age' #  The column header for your age covariate
sexColumnHeader='Sex' #  The column header for your sex covariate
maleIndicator=1       #  What is the indicator for males in the sex column (M? 1? 2? ... )
patients=0            #  Does your dataset contain patients? (mark 0 for no, 1 for yes). If your sample has patients and
                      	#    controls make sure you have a column, (called 'AffectionStatus') where patients are marked with 1 and healthy controls with a 0.

#
# Output diriectory for the ped and dat file outputs (folder will be created for you)
#
peddatdir=/ENIGMA/GCLUSTGWAS/E3/PedDat/

#
#Does you sample have related or unrelated subjects?
#

related=0  # Mark 0 for unrelated sample, 1 for related

if [ $related -eq 0 ]
then
mach2qtl_DL=0                       				# UNRELATED ONLY: Have you downloaded the custom version of mach2qtl yet? Mark 0 for no, 1 for yes
run_machdir=${run_directory}/mach2qtl/              # UNRELATED ONLY: Directory where you will download and compile mach2qtl installed (probably can leave as is)
localfamFILE="None"                 				# UNRELATED ONLY: Keep as is.
else
localfamFILE=/ENIGMA/GCLUSTGWAS/local.fam      		# RELATED ONLY: Path to your local.fam file outputted during the Genetic Imputation step
merlin_DL=0                                         # RELATED ONLY: Have you downloaded and compiled the custom version of merlin-offline yet? Mark 0 for no, 1 for yes
merlin_directory=${run_directory}/merlin/           # RELATED ONLY: Create a directory to download and compile the merlin code (probably can leave as is)
fi

######################################
######## END USER INPUTS #############
######################################








######## Begin ENIGMA phenotypes / covariate inputs #########
eName="E3_GCLUST"  ## what type of ENGIMA analysis are you doing here?
## so far your options include "DTI" or "E3_cortex"
## here we can run formating scripts particular to an ENIGMA analysis - at the end we need (1) a set of ROI/column headers and (2) a set of covariates to move forward.

######## we have some scripts ready for analysis-specific phenotype/covariate formatting
if [ "$eName" == "DTI" ]
then
## set ROIS
ALL_ROIS="ACR;ALIC;AverageFA;BCC;CC;CGC;CGH;CR;EC;FXST;GCC;IC;PCR;PLIC;PTR;RLIC;SCC;SCR;SFO;SLF;SS"
else
	if [ "$eName" == "E3_cortex" ]
	then
		## set ROIS
		ALL_ROIS="Mean_bankssts_surfavg;Mean_caudalanteriorcingulate_surfavg;Mean_caudalmiddlefrontal_surfavg;Mean_cuneus_surfavg;Mean_entorhinal_surfavg;Mean_fusiform_surfavg;Mean_inferiorparietal_surfavg;Mean_inferiortemporal_surfavg;Mean_isthmuscingulate_surfavg;Mean_lateraloccipital_surfavg;Mean_lateralorbitofrontal_surfavg;Mean_lingual_surfavg;Mean_medialorbitofrontal_surfavg;Mean_middletemporal_surfavg;Mean_parahippocampal_surfavg;Mean_paracentral_surfavg;Mean_parsopercularis_surfavg;Mean_parsorbitalis_surfavg;Mean_parstriangularis_surfavg;Mean_pericalcarine_surfavg;Mean_postcentral_surfavg;Mean_posteriorcingulate_surfavg;Mean_precentral_surfavg;Mean_precuneus_surfavg;Mean_rostralanteriorcingulate_surfavg;Mean_rostralmiddlefrontal_surfavg;Mean_superiorfrontal_surfavg;Mean_superiorparietal_surfavg;Mean_superiortemporal_surfavg;Mean_supramarginal_surfavg;Mean_frontalpole_surfavg;Mean_temporalpole_surfavg;Mean_transversetemporal_surfavg;Mean_insula_surfavg;Mean_bankssts_thickavg;Mean_caudalanteriorcingulate_thickavg;Mean_caudalmiddlefrontal_thickavg;Mean_cuneus_thickavg;Mean_entorhinal_thickavg;Mean_fusiform_thickavg;Mean_inferiorparietal_thickavg;Mean_inferiortemporal_thickavg;Mean_isthmuscingulate_thickavg;Mean_lateraloccipital_thickavg;Mean_lateralorbitofrontal_thickavg;Mean_lingual_thickavg;Mean_medialorbitofrontal_thickavg;Mean_middletemporal_thickavg;Mean_parahippocampal_thickavg;Mean_paracentral_thickavg;Mean_parsopercularis_thickavg;Mean_parsorbitalis_thickavg;Mean_parstriangularis_thickavg;Mean_pericalcarine_thickavg;Mean_postcentral_thickavg;Mean_posteriorcingulate_thickavg;Mean_precentral_thickavg;Mean_precuneus_thickavg;Mean_rostralanteriorcingulate_thickavg;Mean_rostralmiddlefrontal_thickavg;Mean_superiorfrontal_thickavg;Mean_superiorparietal_thickavg;Mean_superiortemporal_thickavg;Mean_supramarginal_thickavg;Mean_frontalpole_thickavg;Mean_temporalpole_thickavg;Mean_transversetemporal_thickavg;Mean_insula_thickavg;Mean_Full_SurfArea;Mean_Full_Thickness"
	else
        if [ "$eName" == "E3_GCLUST" ]
	then
		## set ROIs
		ALL_ROIS="Mean_motorpremotor_surfavg;Mean_motor_premotor_SMA_thickavg;Mean_occipital_surfavg;Mean_ventralfrontal_thickavg;Mean_posterolateraltemporal_surfavg;Mean_ventromedialoccipital_thickavg;Mean_superiorparietal_surfavg;Mean_inferiorparietal_thickavg;Mean_orbitofrontal_surfavg;Mean_middletemporal_thickavg;Mean_superiortemporal_surfavg;Mean_perisylvian_thickavg;Mean_inferiorparietal_surfavg;Mean_dorsolateralprefrotal_thickavg;Mean_dorsomedialfrontal_surfavg;Mean_occipital_thickavg;Mean_anteromedialtemporal_surfavg;Mean_temporalpole_thickavg;Mean_precuneus_surfavg;Mean_superiorparietal_thickavg;Mean_dorsolateralprefrontal_surfavg;Mean_medialprefrontal_thickavg;Mean_parsopercularis_surfavg;Mean_medialtemporal_thickavg"  

	else
		echo "this is not yet an ENIGMA analysis compatable with these pipelines"
	fi
fi

##
######## END ENIGMA inputs #########


######## No need to edit below this line #########

# make sure all files are downloaded and installed for GWAS
if [ $related -eq 0 ]
then
    if [ $mach2qtl_DL -eq 0 ]
    then
    mkdir ${run_machdir}
    cd ${run_machdir}
    wget "http://enigma.ini.usc.edu/wp-content/uploads/2015/07/mach2qtl.source.V112_enigma.tgz"
    tar -zxvf mach2qtl.source.V112_enigma.tgz #mach2qtl.tar.gz
		mv mach2qtl.source.V112_enigma/* ./
    make all
			if [ -f ${run_machdir}/executables/mach2qtl ] && [ -f ${run_machdir}/mach2qtl/Main.cpp.orig ];
				then
   				echo "The modified version of mach2qtl exists"
				else
   				echo "The modified version of mach2qtl could not be found"
					exit 1;
			fi
    fi
else
    if [ $merlin_DL -eq 0 ]
    then
		## download merlin and compile the code
    mkdir ${merlin_directory}
    cd ${merlin_directory}
    wget "http://enigma.ini.usc.edu/wp-content/uploads/2015/07/merlin-1.1.2_enigma.tgz"
    tar -zxvf merlin-1.1.2_enigma.tgz
		mv merlin-1.1.2_enigma/* ./
    make all
    cp 1KGPminimac2merlin.pl ../
    chmod -R 755 ./*
			if [ -f ${merlin_directory}/executables/merlin-offline ] && [ -f ${merlin_directory}/libsrc/PedigreeGlobals.cpp.1 ];
				then
					echo "The modified version of merlin-offline exists"
				else
					echo "The modified version of merlin-offline could not be found"
					exit 1;
			fi
    fi
fi

#cd to the run_directory
cd ${run_directory}

# run R script to create ped and dat files for GWAS. eName will name outputs accordingly
if [ "$eName" == "DTI" ]
then
	${Rbin} --no-save --slave --args ${csvFILE} ${localfamFILE} ${combinedROItableFILE} ${ageColumnHeader} ${sexColumnHeader} ${maleIndicator} ${patients} ${related} ${peddatdir} ${ALL_ROIS} ${eName} <  createDatPed_flexible_files.R
elif [ "$eName" == "E3_cortex" ]
then
	${Rbin} --no-save --slave --args ${csvFILE} ${localfamFILE} ${combinedROItableFILE} ${ageColumnHeader} ${sexColumnHeader} ${maleIndicator} ${patients} ${related} ${peddatdir} ${ALL_ROIS} ${eName} <  createDatPed_flexible_files_E3.R


elif [ "$eName" == "E3_GCLUST" ]
then
        ${Rbin} --no-save --slave --args ${csvFILE} ${localfamFILE} ${combinedROItableFILE} ${ageColumnHeader} ${sexColumnHeader} ${maleIndicator} ${patients} ${related} ${peddatdir} ${ALL_ROIS} ${eName} <  createDatPed_flexible_files_E3.R
fi
fi

## remove this file because we have adjusted for the effects of global surface area or thickness when generating phenotypes.
if [[ -e ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_healthy.dat ]] ;then rm ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_healthy.dat; fi
if [[ -e ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_fullGroup.dat ]] ;then rm ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_fullGroup.dat; fi
if [[ -e ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_patients.dat ]] ;then rm ${peddatdir}/ENIGMA_E3_GCLUST_DATfile_patients.dat; fi

