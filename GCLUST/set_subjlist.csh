#!/bin/tcsh
# DJH Aug 2014

setenv SUBJECTS_DIR /usr/enigma/FSoutput # edit as necessary

set outdir = $SUBJECTS_DIR'/GCLUST'
set datadir = $outdir'/surfdata'

mkdir -p $datadir

# create list of FreeSurfer subjects
set fname_subjlist = $datadir'/subjlist.txt'
set cmd = "set_subjlist('"$SUBJECTS_DIR"','"$fname_subjlist"')"
matlab -nosplash -nojvm -r \
  "try, $cmd; exit; catch e, fprintf('ERROR in matlab: %s\n',e.message); exit; end;"

