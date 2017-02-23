#/*
# * some (hopefully) useful functions
# * Neda Jahanshad - neda.jahanshad@ini.usc.edu
# * ENIGMA_DTI 2014.
# */
####################################################################

## function to move columns around from the following post:
#### http://stackoverflow.com/questions/18339370/reordering-columns-in-a-large-dataframe
moveMe <- function(data, tomove, where = "last", ba = NULL) {
    temp <- setdiff(names(data), tomove)
    x <- switch(
    where,
    first = data[c(tomove, temp)],
    last = data[c(temp, tomove)],
    before = {
        if (is.null(ba)) stop("must specify ba column")
        if (length(ba) > 1) stop("ba must be a single character string")
        data[append(temp, values = tomove, after = (match(ba, temp)-1))]
    },
    after = {
        if (is.null(ba)) stop("must specify ba column")
        if (length(ba) > 1) stop("ba must be a single character string")
        data[append(temp, values = tomove, after = (match(ba, temp)))]
    })
    x
}

estimateRelatedness_2gen <- function(data, FID=data$FID, IID=data$IID, PID=data$PID, MID=data$MID, sex=data$Sex, MDS1=data$C1, MDS2=data$C2, MDS3=data$C3,MDS4=data$C4, nullVALUE=0){
    numsubjects = length(IID);
    K = diag(numsubjects);
    zyg=as.vector(rep(0,numsubjects))
    mzindex<- -1;
    dzindex<- 0;
    #Loop over the relationship of each subject to every other subject
    for (i in 1:(numsubjects-1)) {
        # if parents are in the database, add in parent-child relationships
        if (length(IID[which(is.element(IID,PID[i]))]) > 0 ) {
            ii=which(is.element(IID,PID[i]))
            K[i,ii]=0.5; K[ii,i]=0.5; };
        if (length(IID[which(is.element(IID,MID[i]))]) > 0 ) {
            ii=which(is.element(IID,MID[i]))
            K[i,ii]=0.5; K[ii,i]=0.5; };
        # if grandparents are in the database, add in grandparent-child relationships
        if (length(PID[which(is.element(IID,PID[i]))]) > 0 ) {
            ii=which(is.element(IID,PID[i])) ## the parent of IID[i]
            iii=which(is.element(IID,PID[ii])) ## the gparent of IID[i]
            K[i,iii]=0.25; K[iii,i]=0.25 };
        if (length(MID[which(is.element(IID,PID[i]))]) > 0 ) {
            ii=which(is.element(IID,PID[i])) ## the parent of IID[i]
            iii=which(is.element(IID,MID[ii])) ## the gparent of IID[i]
            K[i,iii]=0.25; K[iii,i]=0.25 };
        if (length(PID[which(is.element(IID,MID[i]))]) > 0 ) {
            ii=which(is.element(IID,MID[i])) ## the parent of IID[i]
            iii=which(is.element(IID,PID[ii])) ## the gparent of IID[i]
            K[i,iii]=0.25; K[iii,i]=0.25 };
        if (length(MID[which(is.element(IID,MID[i]))]) > 0 ) {
            ii=which(is.element(IID,MID[i])) ## the parent of IID[i]
            iii=which(is.element(IID,MID[ii])) ## the gparent of IID[i]
            K[i,iii]=0.25; K[iii,i]=0.25 };
        
        for (j in (i+1):numsubjects) {
            if (K[i,j]==0) { ## if we still don't know the relationship yet
            
            #determine if individuals are in the same family
            if (FID[i]==FID[j]) {
                #are the parents the same?
                if (PID[i] == PID[j] && MID[i] == MID[j]) {
                    K[i,j] = 0.5; K[j,i] = 0.5; # they are at least siblings, edit further below:
                    if (sex[i]==sex[j] && ( MDS1[i]==MDS1[j] && MDS2[i]==MDS2[j] && MDS3[i]==MDS3[j] && MDS4[i]==MDS4[j]) ) {
                        K[i,j] = 1 ; K[j,i] = 1 ; # we are assuming here that if the first 4 MDS components are the same between the 2, they are MZ twins
                        if (zyg[i]==0 && zyg[j]==0) {  mzindex=mzindex+2; zyg[i]=mzindex; zyg[j]=mzindex;
                        } else if (zyg[i]==0 && (zyg[j] %% 2 ==1) ) { zyg[i] = zyg[j];
                        } else if (zyg[j]==0 && (zyg[i] %% 2 ==1) ) { zyg[j] = zyg[i]; }
                    
                   } else { 
                     if (zyg[i]==0 && zyg[j]==0) {  dzindex=dzindex+2; zyg[i]=dzindex; zyg[j]=dzindex;
                    } else if (zyg[i]==0 && (zyg[j] %% 2 ==0) ) { zyg[i] = zyg[j];
                    } else if (zyg[j]==0 &&  (zyg[i] %% 2 ==0) ) { zyg[j] = zyg[i]; } }
                    
                # look for 1/2 sibs with only one parent in common
                } else if (PID[i] == PID[j] || MID[i] == MID[j]){
                    K[i,j] = 0.25;}
                
                ## looking for 1st cousins now
                Kic=0;
                for (c in 1:numsubjects) {
                    if (K[i,j]==0 && K[i,c]==K[j,c] && K[i,c]!=0) { Kic=Kic+K[i,c]; }}
                    K[i,j]=sqrt(Kic);
                } ## ends same family
            }
        }
    }
    output=list("KxK"=K,"zygosity"=zyg)
   return(output)
} ## end function

unweightedMean <- function(xL, xR) {
   xM <- (xL + xR)/2
 	output=list("meanLR"=xM)
   return(output)
}

###Functions used in the code for Cohens d
d.t.unpaired<-function(t.val,n1,n2){
  d<-t.val*sqrt((n1+n2)/(n1*n2))
  names(d)<-"effect size d"
  return(d)
}

partial.d<-function(t.val,df,n1,n2){
  d<-t.val*(n1+n2)/(sqrt(n1*n2)*sqrt(df))
  names(d)<-"effect size d"
  return(d)
}

CI_95<-function(ES,se){
  ci<-c((ES-(1.96)*se),(ES+(1.96)*se))
  names(ci)<-c("95% CI lower","95% CI upper")
  return(ci)
}

se.d2<-function(d,n1,n2){
  se<-sqrt((n1+n2)/(n1*n2)+(d^2)/(2*(n1+n2-2)))
  names(se)<-"se for d"
  return(se)
}
######

#remove_lateralized_DTI <- function(merged_temp_rest,VarNames)
## merged_temp_rest is the spreadsheet after not including the standard formated columns like FID (see createDatPed*.)
#bilateral_ROI_list=NULL;
#	for (l in 1:length(VarNames)){
 #   	if (substring(VarNames[l],nchar(VarNames[l])-1,nchar(VarNames[l]))==".L") {
#        	columnnames = colnames(merged_temp_rest);
#       	 merged_temp_rest=merged_temp_rest[,-which(columnnames==VarNames[l])]
#    	 } else if (substring(VarNames[l],nchar(VarNames[l])-1,nchar(VarNames[l]))==".R") {
#        	columnnames = colnames(merged_temp_rest);
#      	 merged_temp_rest=merged_temp_rest[,-which(columnnames==VarNames[l])]
#    	} else {
#       	 bilateral_ROI_list=cbind(bilateral_ROI_list,VarNames[l])
#   	 }
#	}
#	output=list("bilateral_ROI_list"=bilateral_ROI_list,"merged_temp_rest"=merged_temp_rest)
#   return(output)
#}
