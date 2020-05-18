function mtVar = load(mt0, filename)
% LOAD Lazy loading of data into a mapped tensor.
%   Supported formats:
%   | Extension         | Description               |
%   |-------------------|---------------------------|
%   | EDF               | ESRF Data Format          |
%   | POS               | Atom Probe Tomography     |
%   | NPY               | Python NumPy array        |
%   | MRC MAP CCP4 RES  | MRC MRC/CCP4/MAP electronic density map |
%   | MAR               | MAR CCD image             |
%   | IMG MCCD          | ADSC X-ray detector image |
%
% Not implemented
%     VOL + PAR PyHST2 volume reconstruction
%     Analyze   Mayo Clinic volume

mtVar = [];

if nargin < 2, disp('not enough args'); return; end
if ~ischar(filename) && ~iscellstr(filename), disp('not a file'); return; end

% handle multiple files to load
if ischar(filename) && size(filename,1) > 1
  filename = cellstr(filename);
end

if iscell(filename) && numel(filename) > 1
  for index=1:numel(filename)
    mtVar = [ mtVar load(mt0, filename{index}) ];
  end
  return
end

% now single file --------------------------------------------------------------

% handle single file name (possibly with wildcard)
if ~isempty(find(filename == '*')) | ~isempty(find(filename == '?'))  % wildchar !!#
  [filepath,name,ext]=fileparts(filename);  % 'file' to search
  if isempty(filepath), filepath = pwd; end
  this_dir = dir(filename);
  if isempty(this_dir), return; end % directory is empty
  % removes '.' and '..'
  index    = find(~strcmp('.', {this_dir.name}) & ~strcmp('..', {this_dir.name}));
  this_dir = char(this_dir.name);
  this_dir = (this_dir(index,:));
  if isempty(this_dir), return; end % directory only contains '.' and '..'
  rdir     = cellstr(this_dir); % original directory listing as cell
  rdir     = strcat([ filepath filesep ], char(rdir));
  filename = cellstr(rdir);
  mtVar = [ mtVar load(mt0, filename) ];
  return
end

if strncmp(filename, 'file://', length('file://'))
  filename = filename(7:end); % remove 'file://' from local name
end
% handle the '%20' character replacement as space (from URL)
filename = strrep(filename, '%20',' ');

% handle ~ substitution for $HOME
if filename(1) == '~' && (length(filename==1) || filename(2) == '/' || filename(2) == '\')
  filename(1) = '';
  if usejava('jvm')
    filename = [ char(java.lang.System.getProperty('user.home')) filename ];
  elseif ~ispc  % does not work under Windows
    filename = [ getenv('HOME') filename ];
  end
end

if isempty(dir(filename))
  error([ mfilename ': ERROR: Invalid filename ' filename ]);
end
% get file type / extension
[p,f,e] = fileparts(filename);

% each loader should specify the Offset, Format, MachineFormat, Dimensions
args = {}; header = [];
switch upper(e)
case '.EDF'
  [Descr,args] = private_load_edf(filename);
case '.POS'
  [Descr,args] = private_load_pos(filename);
case '.NPY'
  [Descr,args,header] = private_load_npy(filename);
case {'.MRC','.MAP','.CCP4','.RES'}
  [Descr,args,header] = private_load_mrc(filename);
case {'.MAR','.MCCD'}
  [Descr,args,header] = private_load_mar(filename);
case '.SMV' % ADSC (IMG/SMV)
  [Descr,args,header] = private_load_smv(filename);
case '.IMG'
  % ADSC (IMG/SMV)
  [Descr,args,header] = private_load_smv(filename);
otherwise
  error([ mfilename ': unsupported file type ' upper(e) ' for ' filename ]);
end

% success: map file
if ~isempty(Descr)
  disp([ mfilename ': lazy loading ' filename ' ' Descr ]);
  mtVar = MappedTensor('Filename', filename, args{:});
  mtVar.Temporary = false;
  mtVar.Writable  = false; % protect data
  mtVar.UserData  = header;
end

