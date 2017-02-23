#/*
# * Remove lateralized DTI - ROIs and other ROIs we do not want to run GWAS on
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA_DTI 2014.
# */
####################################################################
cmdargs = commandArgs(trailingOnly=T);
TableFile=cmdargs[1]
outFolder=cmdargs[2]
#################

#source('ENIGMA_functions.R')


InfoFile <- data.frame(read.csv(TableFile,colClasses = "character"))
InfoFile_NEW <- InfoFile
VarNames=names(InfoFile)

remainder_list=NULL;
	for (l in 1:length(VarNames)){
    	if ((substring(VarNames[l],nchar(VarNames[l])-1,nchar(VarNames[l]))==".L") || (substring(VarNames[l],nchar(VarNames[l])-1,nchar(VarNames[l]))==".R")) {
			print(paste('The ROI ', VarNames[l], ' will be removed and not analyzed in the GWAS.'))
			columnnames = colnames(InfoFile_NEW);
			InfoFile_NEW=InfoFile_NEW[,-which(columnnames==VarNames[l])]
		} else if (VarNames[l] == "UNC" || VarNames[l] == "IFO"|| VarNames[l] == "CST" || VarNames[l] == "FX") {
			columnnames = colnames(InfoFile_NEW);
			InfoFile_NEW=InfoFile_NEW[,-which(columnnames==VarNames[l])]
			print(paste('The ROI ', VarNames[l], ' will be removed and not analyzed in the GWAS.'))
    	} else {
       	 remainder_list=cbind(remainder_list,VarNames[l])
   	 }
	}
	
	print("the remaining columns are:")
	print(remainder_list)
	
write.csv(InfoFile_NEW,paste(outFolder,"/combinedROItable_eDTI4GWAS.csv",sep=""),quote=F,col.names=T,row.names=F);

