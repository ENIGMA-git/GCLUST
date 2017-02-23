# GCLUST Phenotype Extraction Protocol

*December 3, 2014*

**Written by Chi-Hua Chen and Donald Hagler**

Use this protocol for the analysis of mean cortical thickness and surface area 
data within fuzzy cluster ROIs defined based on genetic correlations for the 
Cortical GWAS Meta-Analysis – ENIGMA3.

If you have any questions or run into problems, please feel free to contact us: 
(chc101@ucsd.edu) and (dhagler@ucsd.edu)

These protocols are offered with an unlimited license and without warranty.  
However, if you find these protocols useful in your research, please provide a 
link to the ENIGMA website in your work: www.enigma.ini.usc.edu

---

### **Extract FreeSurfer measures with cortical surface genetic clusters**

*Italicized* portions of the instructions may require you to make changes so 
that the commands work on your system and data.

This section assumes that you have already run the Image Processing Protocols 
Step 1-3 of ENIGMA3 
(http://enigma.ini.usc.edu/ongoing/gwasma-of-cortical-measures/).

NOTE: It is recommended that these analyses be performed on data that have been 
processed with FreeSurfer v5.3. If your data have not been processed with this 
version, please consider re-running –autorecon3 with the v5.3 binaries and using 
those cortical segmentations for this protocol (additional QC should not be 
required). If for some reason re-analyzing your data is not feasible note that 
v5.2 and versions prior to v5.0 ARE NOT COMPATIBLE with this protocol. If you 
have any questions please contact Don (dhagler@ucsd.edu) and Chi-Hua 
(chc101@ucsd.edu). 
 
---

*	Download the all the files in the GCLUST directory:
```
svn checkout https://github.com/ENIGMA-git/ENIGMA/trunk/GCLUST
```
*	Move the directory `GCLUST` to the parent folder of your FreeSurfer output. 
	For example:

```
Subject1/	Subject2/	Subject3/	Subject4/	GCLUST
```

*	Within this parent directory, make sure that the fsaverage is available. In 
	the tcsh shell:

<pre>
setenv FREESURFER_HOME <i>/usr/local/freesurfer-5.3.0_64bit</i>
ln -s ${FREESURFER_HOME}/subjects/fsaverage .
</pre>

*	Change directories (cd) into the `GCLUST` directory.

---

Create a list of FreeSurfer subject directories to be included in the result 
spreadsheets using the `set_subjlist.csh` script.

*	Open the `set_subjlist.csh` script in any text editor and edit the 
	environment variable:

<pre>
setenv SUBJECTS_DIR <i>/usr/enigma/FSoutput</i>
</pre>

*note: this is where you find the reconstructed freesurfer data for all 
subjects*

*	Save changes
*	Run the script:

```
./set_subjlist.csh
```

**Important**: This will create a subdirectory called surfdata containing a file 
called subjlist.txt. Verify that the entries included in this file are correct. 
**Quality Checking**: Remove all rows in the resultant subjlist.txt file for 
subjects that were marked as poorly segmented for the whole subject in *Step 2 
for Quality Checking of Outputs*. Make sure to save the subjlist.txt file.

---

Resample FreeSurfer surface measures to the atlas and extract weighted averages 
using fuzzy cluster ROIs based on genetic correlations using the `gclust.csh` 
script.

*	Open the `gclust.csh` script in any text editor and edit environment 
	variables:
	
<pre>
setenv FREESURFER_HOME <i>/usr/local/freesurfer-5.3.0_64bit</i>
</pre>

<pre>
setenv SUBJECTS_DIR <i>/usr/enigma/FSoutput</i>
</pre>

*note: this is where you find the reconstructed freesurfer data for all 
subjects*

```
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

*note: in a typical FreeSurfer setup, you must edit this SetUpFreeSurfer.sh 
file*

*	Save changes
*	Run the script:

```
gclust.csh
```

---

After extracting FreeSurfer measures with cortical surface genetic clusters, 
you should have two files called gclust_thickness.csv and gclust_area.csv. 
There should be 25 columns in each file (the first column is Subject ID, then 
12 ROIs for the left hemisphere and 12 ROIs for the right hemisphere). All the 
subjects marked as poorly segmented in the QC Steps were removed. The values in 
the csv files are already adjusted for global effects. 

If these genetically based parcellations for surface area and cortical 
thickness were used, please cite the following papers.

*	[Hierarchical genetic organization of human cortical surface area.](https://www.ncbi.nlm.nih.gov/pubmed/22461613) 
	Chen CH, Gutierrez ED, Thompson W, Panizzon MS, Jernigan TL, Eyler LT, 
	Fennema-Notestine C, Jak AJ, Neale MC, Franz CE, Lyons MJ, Grant MD, Fischl 
	B, Seidman LJ, Tsuang MT, Kremen WS, Dale AM. Science. 2012
*	[Genetic topography of brain morphology.](https://www.ncbi.nlm.nih.gov/pubmed/24082094) 
	Chen CH, Fiecas M, Gutiérrez ED, Panizzon MS, Eyler LT, Vuoksimaa E, 
	Thompson WK, Fennema-Notestine C, Hagler DJ Jr, Jernigan TL, Neale MC, 
	Franz CE, Lyons MJ, Fischl B, Tsuang MT, Dale AM, Kremen WS. PNAS. 2013
	
Feel free to send questions to Don (dhagler@ucsd.edu) and Chi-Hua 
(chc101@ucsd.edu). 
