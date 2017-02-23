#!/bin/tcsh
# LTW Dec 2013
# DJH Aug 2014

setenv FREESURFER_HOME /usr/local/freesurfer-5.3.0_64bit # edit as necessary
setenv SUBJECTS_DIR /usr/enigma/FSoutput # edit as necessary
source $FREESURFER_HOME/SetUpFreeSurfer.sh # edit as necessary

# set some variables
set nsmooth = 705
set area = "white"
set meas = "thickness"
set volume = "volume"
set target = "fsaverage"

set outdir = $SUBJECTS_DIR'/GCLUST'
set matlabdir = $outdir'/matlab'
set roidir = $outdir'/clusters'
set datadir = $outdir'/surfdata'

mkdir -p $datadir

# create list of FreeSurfer subjects
set fname_subjlist = $datadir'/subjlist.txt'
if (! -e $fname_subjlist) then
  set cmd = "set_subjlist('"$SUBJECTS_DIR"','"$fname_subjlist"')"
  matlab -nosplash -nojvm -r \
    "try, $cmd; exit; catch e, fprintf('ERROR in matlab: %s\n',e.message); exit; end;"
endif

# run for each hemisphere
foreach hemi (lh rh)

  # resample thickness to common space and concatenate 
  set out="${datadir}/${hemi}.${meas}"
  mris_preproc --out ${out}.mgh \
  --target ${target} \
  --f $fname_subjlist \
  --hemi $hemi \
  --meas ${meas} \

  # smooth thickness
  mri_surf2surf \
    --s $target \
    --sval ${out}.mgh \
    --cortex \
    --nsmooth-out $nsmooth \
    --tval ${out}.n${nsmooth}.mgh \
    --hemi $hemi

  # resample surface area to common space and concatenate 
  set out="${datadir}/${hemi}.${area}"
  mris_preproc --out ${out}.mgh \
  --target ${target} \
  --f $fname_subjlist \
  --hemi $hemi \
  --area $area \

  # smooth surface
  mri_surf2surf \
    --s $target \
    --sval ${out}.mgh \
    --cortex \
    --nsmooth-out $nsmooth \
    --tval ${out}.n${nsmooth}.mgh \
    --hemi $hemi

end

# extract weighted averages for area and thickness for each cluster
set cmd = "gclust('"$datadir"','"$roidir"','"$matlabdir"','"$outdir"')"
matlab -nosplash -nojvm -r \
  "try, $cmd; exit; catch e, fprintf('ERROR in matlab: %s\n',e.message); exit; end;"

