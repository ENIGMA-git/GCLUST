function set_subjlist(subjdir,fname_subjlist)
%function set_subjlist(subjdir,fname_subjlist)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hemilist = {'lh','rh'};
forceflag = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(fname_subjlist,'file') || forceflag
  fid = fopen(fname_subjlist,'wt');
  if fid<0
    error('failed to create file %s',fname_subjlist);
  end;
  dlist = dir(sprintf('%s/*',subjdir));
  for i=1:length(dlist)
    subj = dlist(i).name;
    if ismember(subj,{'.','..'}), continue; end;
    if ~isempty(regexp(subj,'fsaverage')), continue; end;
    dirname = sprintf('%s/%s',subjdir,subj);
    subjflag = 1;
    for h=1:length(hemilist)
      hemi = hemilist{h};
      fname_reg = sprintf('%s/surf/%s.sphere.reg',dirname,hemi);
      if ~exist(fname_reg,'file')
        subjflag = 0;
        break;
      end;
    end;
    if subjflag
      fprintf(fid,'%s\n',subj);
    end;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
