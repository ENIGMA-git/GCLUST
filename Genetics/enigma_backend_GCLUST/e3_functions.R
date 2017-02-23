#/*
# * Derrek Hibar  - derrek.hibar@ini.usc.edu
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * Modified by Chi-Hua Chen  - chc101@ucsd.edu
# * ENIGMA 2015.
# */
####################################################################
cmdargs = commandArgs(trailingOnly=T);
csvFILE_SA=cmdargs[1]
csvFILE_TH=cmdargs[2]
outFolder=cmdargs[3]
#################

ROIS_SA=c("motorpremotor","occipital","posterolateraltemporal","superiorparietal","orbitofrontal","superiortemporal","inferiorparietal","dorsomedialfrontal","anteromedialtemporal","precuneus","dorsolateralprefrontal","parsopercularis")

ROIS_TH=c("motor_premotor_SMA","ventralfrontal","ventromedialoccipital","inferiorparietal","middletemporal","perisylvian","dorsolateralprefrotal","occipital","temporalpole","superiorparietal","medialprefrontal","medialtemporal")

ROIS2=c("SurfArea","Thickness")

#SA <- data.frame(read.csv(csvFILE_SA))
#TH <- data.frame(read.csv(csvFILE_TH))

SA <- data.frame(read.csv(csvFILE_SA,colClasses = "character")) # if you have column names with unstandard symbols ("-") use this
TH <- data.frame(read.csv(csvFILE_TH,colClasses = "character")) 

VarNamesSA=names(SA)
VarNamesTH=names(TH)

NsubjSA=dim(SA)[1]
NsubjTH=dim(TH)[1]

subjectNames=SA[,1]

if (NsubjSA != NsubjTH) {
	stop("Number of Subjects with cortical thickness measures do not match those with surface area. Please make sure your files are correct.")
}

Avg_ALL=cbind(subjectNames)
colnames(Avg_ALL)=c("SubjID")

for (i in 1:length(ROIS_SA)) {
	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste(ROIS_SA[i],".lh.area",sep="")
	R_roi=paste(ROIS_SA[i],".rh.area",sep="")
	AVG_roi=paste("Mean_",ROIS_SA[i],"_surfavg",sep="")
	#tmp = 0.5*(SA[,which(VarNamesSA==L_roi)]+SA[,which(VarNamesSA==R_roi)])
	     tmp = 0.5*(as.numeric(SA[,which(VarNamesSA==L_roi)])+ as.numeric(SA[,which(VarNamesSA==R_roi)])) # if you have column names with unstandard symbols ("-") use this
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)

	ALLcolnames = colnames(Avg_ALL);
	L_roi=paste(ROIS_TH[i],".lh.thickness",sep="")
	R_roi=paste(ROIS_TH[i],".rh.thickness",sep="")
	AVG_roi=paste("Mean_",ROIS_TH[i],"_thickavg",sep="")
	#tmp = 0.5*(TH[,which(VarNamesTH==L_roi)]+TH[,which(VarNamesTH==R_roi)])
	     tmp = 0.5*(as.numeric(TH[,which(VarNamesTH==L_roi)])+ as.numeric(TH[,which(VarNamesTH==R_roi)])) # if you have column names with unstandard symbols ("-") use this
	Avg_ALL = cbind(Avg_ALL, tmp)
	colnames(Avg_ALL)<-c(ALLcolnames,AVG_roi)
}


SummaryAvg_ALL = Avg_ALL[,-1]
SummaryAvg_ALL_dat = colMeans(matrix(as.numeric(unlist(SummaryAvg_ALL)),nrow=nrow(SummaryAvg_ALL)), na.rm=T)

write.csv(SummaryAvg_ALL_dat,file=paste0(outFolder,"/SummaryMeasures.csv"),quote=F,row.names=F)

write.csv(Avg_ALL,paste(outFolder,"/CorticalMeasures_ENIGMA_ALL_Avg.csv",sep=""),quote=F,row.names=F);
