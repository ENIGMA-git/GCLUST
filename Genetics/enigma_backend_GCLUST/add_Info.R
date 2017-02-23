#################
# to run this script
# ${Rbin} --no-save --slave --args $TableFile $TableSubjectID_column $Phenotype_table.csv $subjectID_column $N_covariates $covariates $outTable <  add_Info.R
#################
# INPUTS: 
#################
#$TableFile - full path to the table where your covariates are stored
#$TableSubjectID_column - the column where the subject IDs are listed.... [probably something like subjectID or IID or SubjID ...]
#$Phenotype_table.csv - full path to the table where your phenotypes are stored. this is the table you want to add covariates to, for example for eDTI this would be combinedROItable.csv
#$PhenotypeSubjectID_column - the column where the subject IDs are listed in the phenotype tiable.... [probably something like subjectID or IID or SubjID ...]
#$N_covariates - the number of covariates you want to add
#$covariates - a semi-colon separated list of covariates to add, for example "Age;Sex;AffectionStatus;3T"
#$outTable - full path and name to the output table you want to create which has merged all phenotypes and covariates
#################
cmdargs = commandArgs(trailingOnly=T);
TableFile=cmdargs[1]
TableSubjectID_column=cmdargs[2]

ENIGMAPhenoFile=cmdargs[3]
PhenoSubjectID_column=cmdargs[4]

Ncov=as.numeric(cmdargs[5]); ## this is covariates or any other info you want to add such as familyID, MID, PID etc
covariates=cmdargs[6]

outTable=cmdargs[7]
#################

if (substring(TableFile,nchar(TableFile)-3,nchar(TableFile))== ".csv"){
	Table<-read.csv(TableFile,header=T,blank.lines.skip = TRUE)
	columnnamesT<-colnames(Table)
} else {
	Table<-read.table(TableFile,header=T,blank.lines.skip = TRUE)
	columnnamesT<-colnames(Table)
} 
if (substring(ENIGMAPhenoFile,nchar(ENIGMAPhenoFile)-3,nchar(ENIGMAPhenoFile))== ".csv"){
	Pheno<-read.csv(ENIGMAPhenoFile,header=T,blank.lines.skip = TRUE)
	columnnamesP<-colnames(Pheno)
} else {
	Pheno<-read.table(ENIGMAPhenoFile,header=T,blank.lines.skip = TRUE)
	columnnamesP<-colnames(Pheno)
}

###################

matchind = match(Pheno[,which(columnnamesP==PhenoSubjectID_column)],Table[,which(columnnamesT==TableSubjectID_column)]);

DesignMatrix = Pheno[which(!is.na(matchind)),]
TableSmall = Table[matchind[!is.na(matchind)],]
if(length(matchind) == length(which(is.na(matchind)))){
	stop('There are no subjects remaining when matching your Covariates file with your ROI data. Please check that the IDs used match between files.\n')
}
if(length(which(is.na(matchind))) > 0){
	cat('Your TableFile (Covariates File) has missing values.\n')
	cat('These subjects will be removed from the analysis.\n')
	print(Pheno[which(is.na(matchind)),which(columnnamesP==PhenoSubjectID_column)])
}

if (Ncov > 0) {
parsedCov=parse(text=covariates);
for (nc in 1:Ncov) {
	covName<-as.character(parsedCov[nc])
	print(covName)
	origcolnames = colnames(DesignMatrix);
	DesignMatrix = cbind(DesignMatrix, TableSmall[,which(columnnamesT==covName)]);
	colnames(DesignMatrix)<-c(origcolnames,covName);
}
}
print(dim(DesignMatrix))

write.csv(DesignMatrix,outTable,quote=F,row.names=F);

