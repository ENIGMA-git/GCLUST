function geneclust(datadir,roidir,matlabdir,outdir)
%function geneclust(datadir,roidir,matlabdir,outdir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(matlabdir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

measname_list = {'area','thickness'};
datastem_list = {'white.n705','thickness.n705'};
roistem_list = {'gclust_area','gclust_thickness'};
global_flags = [2,1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parms = [];
parms.outdir = outdir;
parms.roistem = 'gclust';
parms.hemilist = {'lh','rh'};
parms.fuzzy_fstem = 'fuzzy';
parms.fuzzy_order = 12;
parms.forceflag = 1;

roistem = sprintf('%s%d',parms.fuzzy_fstem,parms.fuzzy_order);
nhemi = length(parms.hemilist);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(measname_list)
  datastem = datastem_list{i};
  roistem = roistem_list{i};
  
  fnames_data = cell(nhemi,1);
  fnames_roi = cell(nhemi,1);
  for h=1:nhemi
    hemi = parms.hemilist{h};
    fnames_data{h} = sprintf('%s/%s.%s.mgh',datadir,hemi,datastem);
    fnames_roi{h} = sprintf('%s/%s-%s.mgz',roidir,roistem,hemi);
  end;

  fname_subjlist = sprintf('%s/subjlist.txt',datadir);
  parms.subjlist = mmil_readtext(fname_subjlist);
  parms.outstem = roistem;
  parms.measname = measname_list{i};
  parms.global_flag = global_flags(i);

  args = mmil_parms2args(parms);
  mmil_analyze_fuzzy_concat(fnames_data,fnames_roi,args{:});
end;

