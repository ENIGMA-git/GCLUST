#!/bin/bash

#
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * Derrek Hibar - derrek.hibar@ini.usc.edu
# * Modified by Chi-Hua Chen - chc101@ucsd.edu
# * ENIGMA 2014.
# Last edit 2016 Jan 15, by chc

#### Notes for running Step2 (GWAS)
# This script can be run in batch-mode if you have a Sun Grid Engine (qsub)
# 	     Example: qsub -q "qname.q" -t 1:"Nnodes" run2_GWAS_flexible_step2.sh
# If you do not have access to an SGE/qsub compute server, you can run each GWAS in a series locally
#	     Set Nnodes=1, and then run by calling ./run2_GWAS_flexible_step2.sh
# If you want a text file list of commands so that you can batch submit using another system
#        Set Nnodes=1, Set mode="manual", and then run by calling ./run2_GWAS_flexible_step2.sh
#	     This will create text files that can be found in your current working directory
####

##################################
######## USER INPUTS #############
##################################

run_directory=/ENIGMA/GCLUSTGWAS/SCRIPTS/enigma_backend_GCLUST                        # Directory where all the enigma association scripts are stored
Nnodes=1                               							    			# You can split up the processing into this many nodes, if running in series or manually, Nnodes=1
machFILEdir=/ENIGMA/Study_Genotypes/1KGPref/Mach              					# Give the directory to the imputed output from Mach (after imputation scripts)
peddatdir=/ENIGMA/GCLUSTGWAS/E3/PedDat                							# Give the dir to the ped and dat files created in run1_GWAS_flexible_step1.sh
samplename=ADNI									# Give abbreviated name of your sample, no spaces in the name (i.e. ADNI)
GWASout=/ENIGMA/GCLUSTGWAS/GCLUSTGWAS_out     										# Directory for the output from mach2qtl or merlin (folder will be created for you)
mode="run"      																# Can change to "manual" if you want to output a list of commands that you can batch process yourself, otherwise set to "run"
status=H                                										# H for healthy, HD for healthy and disease, (or D for disease-only datasets)

#
# Does you sample have related or unrelated subjects?
#

related=0                                 # 0 for unrelated sample, 1 (or anything else for related)

if [ $related -eq 0 ]
then
run_machdir=${run_directory}/mach2qtl     # give the directory to where you installed and compiled mach2qtl (the parent folder of the executables/ folder)
else
merlin_directory=${run_directory}/merlin                # RELATED ONLY: give the directory to where you installed and compiled Merlin in step 1
merlinFILEdir=/ENIGMA/GCLUSTGWAS/merlin         								  # RELATED ONLY: give the directory to the imputed output for merlin (will be created if files don't exist), see http://genepi.qimr.edu.au/staff/sarahMe/mach2merlin.html
fi

######################################
######## END USER INPUTS #############
######################################

######################################
######## Begin ENIGMA inputs #########
######################################

eName="E3_GCLUST"
## so far your options include "DTI". "E3_cortex" or "E3_GCLUST"

######################################
######## END ENIGMA inputs ###########
######################################



######## No need to edit below this line #########

if [ ! -d ${GWASout} ]; then
mkdir ${GWASout}
fi

if [ $Nnodes -eq 1 ]
then
SGE_TASK_ID=1
fi

if [ $related -eq 0 ]
then
ls -1 ${machFILEdir}/chunk*-ready4mach.*.imputed.dose.gz > ${GWASout}/fileList_${SGE_TASK_ID}.txt
totalFiles=`ls ${machFILEdir}/chunk*-ready4mach.*.imputed.dose.gz |wc -w`
if [ "$eName" == "DTI" ]
then
${run_directory}/ENIGMA_unrelatedGWAS.sh ${run_machdir} $machFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $SGE_TASK_ID $mode
elif [ "$eName" == "E3_cortex" ]
then
${run_directory}/ENIGMA_unrelatedGWAS_E3.sh ${run_machdir} $machFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $SGE_TASK_ID $mode
elif [ "$eName" == "E3_GCLUST" ]
then
${run_directory}/ENIGMA_unrelatedGWAS_E3.sh ${run_machdir} $machFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $SGE_TASK_ID $mode
fi

else                 ## if related, run merlin-offline
ls -1 ${merlinFILEdir}/chunk*-ready4mach.*dat.gz > ${GWASout}/fileList_${SGE_TASK_ID}.txt
totalFiles=`ls ${merlinFILEdir}/chunk*-ready4mach.*.dat.gz |wc -w`
echo $totalFiles
    if [ $totalFiles -eq 0 ]      ## check to see if mach to merlin file conversion has been performed
    then
    mkdir $merlinFILEdir
    ls -1 ${machFILEdir}/chunk*-ready4mach.*.imputed.dose.gz > ${GWASout}/fileList_${SGE_TASK_ID}.txt
    totalFiles=`ls ${machFILEdir}/chunk*-ready4mach.*.imputed.dose.gz |wc -w`
    merlinOFFLINE=0
    else
    ls -1 ${merlinFILEdir}/chunk*-ready4mach.*dat.gz > ${GWASout}/fileList_${SGE_TASK_ID}.txt
    totalFiles=`ls ${merlinFILEdir}/chunk*-ready4mach.*.dat.gz |wc -w`
    merlinOFFLINE=1
    fi
if [ "$eName" == "DTI" ]
then
echo ${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
elif [ "$eName" == "E3_cortex" ]
then
echo ${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE_E3.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE_E3.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
elif [ "$eName" == "E3_GCLUST" ]
then
echo ${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE_E3.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
${run_directory}/ENIGMA_relatedGWAS_merlinOFFLINE_E3.sh $merlin_directory $merlinFILEdir $peddatdir $samplename $GWASout $status $Nnodes $totalFiles ${eName} $merlinOFFLINE $SGE_TASK_ID $mode
fi
fi

