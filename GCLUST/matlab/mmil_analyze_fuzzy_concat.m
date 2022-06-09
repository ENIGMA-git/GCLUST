function mmil_analyze_fuzzy_concat(fnames_data,fnames_roi,varargin)
%function mmil_analyze_fuzzy_concat(fnames_data,fnames_roi,[options])
%
% Purpose: calculate average ico area for weighted ROIs
%
% Required Input:
%   fnames_data: cell array of freesurfer surface data files (mgh/mgz)
%   fnames_roi: cell array of weighted ROI files (mgh/mgz)
%
% Optional Parameters:
%   'roinames': cell array of ROI names
%     if empty, will use mmil_fuzzy_names
%     {default = []}
%   'roistem': stem of column names
%     {default = 'ctx'}
%   'measname': measure name (appended to column names)
%     {default = []}
%   'hemilist': cell array of cortical hemispheres
%     must match fnames_data
%     {default = {'lh','rh'}}
%   'outdir': where to place output files
%     {default = 'analysis'}
%   'outstem': file stem for output csv file
%     {default = 'fuzzy_concat'}
%   'subjlist': cell array of subject names used for row headers
%     must match number of frames in data files
%     if not supplied, will use 'subj1', 'subj2', etc.
%     {default = []}
%   'global_flag': remove global effects from data
%     0: do not remove global effects
%     1: subtract mean value of all vertices (e.g. for thickness)
%     2: divide by mean value of all vertices (e.g. for area)
%     {default = 0}
%   'subjdir': full path of FreeSurfer subject directory
%     containing average subject
%     {default = $FREESURFER_HOME/subjects}
%   'subjname': name of average subject (used to get cortex labels)
%     {default = 'fsaverage'}
%   'forceflag': overwrite existing output
%     {default: 0}
%
% Created:  04/05/14 by Don Hagler
% Last Mod: 06/09/22 by Victor Zeng
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~mmil_check_nargs(nargin,2), return; end;

parms = mmil_args2parms(varargin,{...
  'fnames_data',fnames_data,[],...
  'fnames_roi',fnames_roi,[],...
...
  'roinames',[],[],...
  'roistem','ctx',[],...
  'measname',[],[],...
  'hemilist',{'lh','rh'},{'lh' 'rh'},...
  'subjlist',[],[],...
  'outdir','analysis',[],...
  'outstem','fuzzy_concat',[],...
  'global_flag',0,[0:2],...
  'subjdir',[],[],...
  'subjname','fsaverage',[],...
  'forceflag',false,[false true],...
... % undocumented
  'label_name','cortex',[],...
  'fuzzy_fstem','fuzzy',[],...
  'fuzzy_order',12,[0,1,2,4,12,18],...
...
  'fuzzy_name_tags',{'measname','fuzzy_fstem','fuzzy_order'},[],...
});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(parms.roinames)
  % set names of fuzzy clusters
  args = mmil_parms2args(parms,parms.fuzzy_name_tags);
  parms.fuzzy_names = mmil_fuzzy_names(args{:});
  parms.roinames = parms.fuzzy_names;  
else
  parms.fuzzy_names = [];
  parms.fuzzy_order = length(parms.roinames);
end;
  
parms.nhemi = length(parms.hemilist);

% check that fnames_data matches nhemi
if ~iscell(parms.fnames_data)
  parms.fnames_data = {parms.fnames_data};
end;
if length(parms.fnames_data)~=parms.nhemi
  error('length of fnames_data does not match length of hemilist');
end;

% check that fnames_roi matches nhemi
if ~iscell(parms.fnames_roi)
  parms.fnames_roi = {parms.fnames_roi};
end;
if length(parms.fnames_roi)~=parms.nhemi
  error('length of fnames_roi does not match length of hemilist');
end;

% check files exist
for h=1:parms.nhemi
  if ~exist(parms.fnames_data{h},'file')
    error('file %s not found',parms.fnames_data{h});
  end;
  if ~exist(parms.fnames_roi{h},'file')
    error('file %s not found',parms.fnames_roi{h});
  end;
end;

% check numbers of frames
parms.nframes = [];
for h=1:parms.nhemi
  [tmp,volsz] = fs_read_header(parms.fnames_data{h});
  if isempty(parms.nframes)
    parms.nframes = volsz(4);
  else
    if volsz(4)~=parms.nframes
      error('mismatch in number of frames in data files');
    end;
  end;
end;  

% check subjlist
if ~isempty(parms.subjlist)
  if length(parms.subjlist)~=parms.nframes
    error('length of subjlist does not match number of subjects');
  end;
else
  parms.subjlist = cell(parms.nframes,1);
  for i=1:parms.nsubs
    parms.subjlist{i} = sprintf('subj%d',i);
  end;
end;

% check subj and subjdir
if isempty(parms.subjdir)
  fshomedir = getenv('FREESURFER_HOME');
  if isempty(fshomedir)
    error('FREESURFER_HOME environment variable undefined');
  end;
  parms.subjdir = [fshomedir '/subjects'];
end;
if ~exist(parms.subjdir,'dir')
  error('FreeSurfer subject dir %s not found',parms.subjdir);
end;
fspath = [parms.subjdir '/' parms.subjname];
for h=1:parms.nhemi
  hemi = parms.hemilist{h};
  parms.fnames_label{h} = sprintf('%s/label/%s.%s.label',...
    fspath,hemi,parms.label_name);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mmil_mkdir(parms.outdir);

fname_out = sprintf('%s/%s.csv',parms.outdir,parms.outstem);
if ~exist(fname_out,'file') || parms.forceflag
  roinames = cell(parms.fuzzy_order,parms.nhemi);
  roivals = nan(parms.fuzzy_order,parms.nhemi,parms.nframes);
  for h=1:parms.nhemi
    hemi = parms.hemilist{h};
    fname_data = parms.fnames_data{h};
    fname_roi = parms.fnames_roi{h};
    % load data
    vals_data = fs_load_mgh(fname_data);
    nverts = size(vals_data,1);
    vals_data = reshape(vals_data,[nverts,parms.nframes]);
    % load ROIs
    vals_roi = fs_load_mgh(fname_roi);
    if size(vals_roi,1)~=nverts
      error('mismatch between data and ROI # of vertices');
    end;
    nroi = size(vals_roi,4);
    vals_roi = reshape(vals_roi,[nverts,nroi]);
    if nroi~=parms.fuzzy_order
      error('mismatch between fuzzy_order and number of ROIs');
    end;
    % load cortex label
    v_label = sort(fs_read_label(parms.fnames_label{h}));
    % set weights to zero for non-cortical vertices
    v_exclude = setdiff([1:nverts],v_label);
    vals_roi(v_exclude,:) = 0;
    % remove global effects from data
    if parms.global_flag
      vals_label = vals_data(v_label,:);
      vals_mean = mean(vals_label,1);
      switch parms.global_flag
        case 1
          % subtract the mean value across vertices
          vals_data = bsxfun(@minus,vals_data,vals_mean);
        case 2
          % divide by the sum across vertices
          vals_data = bsxfun(@rdivide,vals_data,vals_mean);
      end;
    end;
    % calculate weighted means for each ROI
    for r=1:nroi
      % set ROI name
      if ~isempty(parms.fuzzy_names)
       tmp_name = regexprep(parms.fuzzy_names{r},...
         sprintf('%s%d_',parms.fuzzy_fstem,parms.fuzzy_order),'');
      else
        tmp_name = sprintf('%s-%s',parms.roinames{r},hemi);
      end;
      if ~isempty(parms.measname)
        tmp_name = [hemi '.' tmp_name '-' parms.measname];
      end;
      roinames{r,h} = tmp_name;
      % calculate weighted averages for this ROI
      weights = repmat(vals_roi(:,r),[1,parms.nframes]);
      roivals(r,h,:) = mmil_wtd_mean(vals_data,weights,1);
    end;
  end;
  % prepare to write results as csv file
  row_labels = parms.subjlist;
  col_labels = reshape(roinames,[parms.nhemi*nroi,1]);
  data = reshape(roivals,[parms.nhemi*nroi,parms.nframes])';
  % write results as csv file
  mmil_write_csv(fname_out,data,'row_labels',row_labels,...
    'col_labels',col_labels,'firstcol_label','SubjID');
end;

