function ret = pack(mtVar, method)
% PACK    Compress the mapped file.
%   Compress tensor storage with ZIP, TAR, GZIP, LZ4, ZSTD, BZIP2, XZ, LZO, ...
%   M = PACK(M) compresses the mapped data files for given tensor.
%   Unpacking is done transparently when data is accessed, or can be forced with
%   UNPACK(M).
%
%   TF = PACK(M, 'check') returns true when the tensor M is compressed.
%
%   You should install the extractors individually.
%   Recommended:
%   * LZ4 <https://lz4.github.io/lz4/> (2011). Extremely fast.
%   * ZSTD <https://github.com/facebook/zstd> (2015). Very fast.
%   * BROTLI <https://github.com/google/brotli> (2013). Very fast.
%   * LZO <https://www.lzop.org/> (1996-2017). Very fast.
%   * PBZIP2 <https://github.com/ruanhuabin/pbzip2>. Parallelized BZIP2.
%   * PIGZ <https://zlib.net/pigz/> (2007). Parallelized GZIP.
%   * PIXZ <https://github.com/vasi/pixz> (2010). Parallelized XZ.
%
%   Other:
%   * ZIP <https://support.pkware.com/home> (1989). Standard.
%   * TAR <https://www.gnu.org/software/tar/>. Standard.
%   * GZIP <https://www.gnu.org/software/gzip/> (1992). Standard.
%   * BZIP2 <https://www.sourceware.org/bzip2/> (1996). Very compact.
%   * LZMA <https://tukaani.org/lzma/> (1998). Slow, efficient.
%   * XZ <https://tukaani.org/xz/>. Rather slow, very compact.
%   * PXZ <https://jnovy.fedorapeople.org/pxz/>. Parallelized XZ.
%   * 7Z <https://www.7-zip.org/> (1998).
%   * RAR <https://www.rarlab.com/> (1993).
%   * COMPRESS (Z) <https://ncompress.sourceforge.io/> (1985).
%
%   Recommended compressors are LZ4, ZSTD, PIGZ and PBZIP2.
%   ZIP, GZIP and TAR are supported without further installation.
%
% Example: m=MappedTensor(eye(1000)); pack(m); pack(m,'check')

persistent present

if isempty(present)
  present = check_compressors;
end

if nargin < 2, method = ''; end

% handle array of objects
if numel(mtVar) > 1
  ret = [];
  for index=1:numel(mtVar)
    ret = [ ret pack(mtVar(index), method) ];
  end
  return
end

flag_decompress = false;

% check current state: already done, or status required ?
switch(method)
case {'decompress','extract','pack'}
  flag_decompress = true;
  method = '';
case {'compress','pack'}
  method = '';
case 'identify'
  ret = present;
  return
case {'check','status'}
  ret= iscompressed(mtVar.Filename, present) || iscompressed(mtVar.FilenameCmplx, present);
  return
end
if isempty(method), method=present(1); end

ret = mtVar;

% launch de/compression
if ~flag_decompress
  if ~iscompressed(mtVar.Filename, present)
    mtVar.bCompressed = 2; % in progress;
    mtVar.Filename      = compress(mtVar.Filename,      method, present);
  end
  if ~iscompressed(mtVar.FilenameCmplx, present)
    mtVar.bCompressed = 2; % in progress;
    mtVar.FilenameCmplx = compress(mtVar.FilenameCmplx, method, present);
  end
  mtVar.bCompressed = 1; % now compressed
  
else
  if iscompressed(mtVar.Filename, present)
    mtVar.bCompressed = 2; % in progress;
    mtVar.Filename      = decompress(mtVar.Filename,      present);
  end
  if iscompressed(mtVar.FilenameCmplx, present)
    mtVar.bCompressed = 2; % in progress;
    mtVar.FilenameCmplx = decompress(mtVar.FilenameCmplx, present);
  end
  mtVar.bCompressed = 0; % now decompressed
end

% ------------------------------------------------------------------------------
function newfile = compress(filename, compressor, present)
% COMPRESS compress filename

  newfile = filename;
  if isempty(filename), return; end

  if ischar(compressor)
    index=find(strcmp(compressor, { present.extension }));
    if isempty(index)
      disp('Available compressors:')
      disp(sprintf(' %s', present.extension))
      error([ mfilename ': can not find compressor ' compressor ]);
    end
    compressor = present(index);
  end

  % compress it
  newfile = [ filename '.' compressor.extension ];
  
  if isa(compressor.compress, 'function_handle') ...
  || strncmp(compressor.compress, 'matlab:', 7)
    % builtin Matlab extractor
    if strncmp(compressor.compress, 'matlab:', 7)
      compressor.compress = compressor.compress(8:end);
    end
    feval(compressor.compress, newfile, filename);
  else
    % compress
    system([compressor.compress ' ' filename ]);
  end
  
  % clean-up
  if ~isempty(dir(filename))
    delete(filename);
  end

% ------------------------------------------------------------------------------
function newfile = decompress(filename, present)
% DECOMPRESS decompress filename locally

  newfile = filename;
  if isempty(filename), return; end

  % identify which compressor is used (from extension)
  [tf,compressor] = iscompressed(filename, present);
  if isempty(compressor)
    return; % not compressed
  end
  
  % decompress it
  [p,f,e] = fileparts(filename);
  newfile = fullfile(p,f); % no extension

  % extract it
  if isa(compressor.decompress, 'function_handle') ...
  || strncmp(compressor.decompress, 'matlab:', 7)
    % builtin Matlab extractor
    if strncmp(compressor.decompress, 'matlab:', 7)
      compressor.decompress = compressor.decompress(8:end);
    end
    filenames = feval(compressor.decompress, filename, p);
  else    
    % extract
    system([compressor.decompress ' ' filename ]);
  end
  
  % remove initial archive from temp dir
  if ~isempty(dir(filename))
    delete(filename);
  end

% ------------------------------------------------------------------------------
function [tf, compressor] = iscompressed(filename, present)
% ISCOMPRESSED check if file is compressed

  tf = false; compressor = [];

  % identify which compressor is used (from extension)
  [p,f,e] = fileparts(filename);
  index   = find(strcmp(lower(e(2:end)), lower({ present.extension })),1);
  if isempty(index), return; end % not an archive
  compressor = present(index);
  tf = true;

% ------------------------------------------------------------------------------
function present = check_compressors(options)
% CHECK_COMPRESSORS check if (de)compressors are present
%
% Supported:
%   ZIP, GZIP, TAR                    (builtin)
%   LZ4, COMPRESS/Z, ZSTD, LZO, BZIP2 (via system)

  present = [];

  % required to avoid Matlab to use its own libraries
  if ismac,      precmd = 'DYLD_LIBRARY_PATH= ; DISPLAY= ; ';
  elseif isunix, precmd = 'LD_LIBRARY_PATH= ;  DISPLAY= ; ';
  else           precmd = ''; end

  %         { EXT,  CHECK,          cmd UNCOMP,      cmd COMP}
  % last extractors should be the default (and less efficient)
  tocheck = {'lz4', 'lz4 --version',    'lz4 -d',        'lz4 -1';
             'zst', 'zstd --version',   'zstd -d',       'zstd -1',;
             'Z',   'compress -V',      'compress -d',    'compress';
             'lzo', 'lzop --version',   'lzop -d',       'lzop -1';
             'gz',  'pigz --version',   'pigz -d',       'pigz -1';
             'bz2', 'pbzip2 --version', 'pbzip2 -d',     'pbzip2 -1';
             'bz2', 'bzip2 --version',  'bzip2 -d',      'bzip2 -1';
             'br',  'brotli --version', 'brotli -d',     'brotli -1';
             'xz',  'pixz -version',   'pixz -d',       'pixz -1';
             'xz',  'pxz --version',    'pxz -d',        'pxz -1';
             'xz',  'xz --version',     'xz -d',         'xz -1';
             'rar', 'rar -version',     'rar x',         'rar a';
             '7z',  '7z i',             '7z x',          '7z a';
             'lzma','lzma --version',   'lzma -d',       'lzma -1';
             'zip', 'matlab:unzip',     'matlab:unzip',  'matlab:zip';
             'gz',  'matlab:gunzip',    'matlab:gunzip', 'matlab:gzip';
             'tgz', 'matlab:untar',     'matlab:untar',  'matlab:tar';
             'tar', 'matlab:untar',     'matlab:untar',  'matlab:tar'};

  for totest = tocheck'
    % look for executable and test with various extensions
    ok = false;
    if isa(totest{2}, 'function_handle') ...
    || strncmp(totest{2}, 'matlab:', 7)
      ok = true;
    else
      [status, result] = system([ precmd totest{2} ]); % usually 127 indicates 'command not found'
    end
    if (isunix && any(status == [0 2])) ...
    || (ispc &&  isempty(strfind(result, [ '''' strtok(totest{1}) '''' ])))
      ok = true;
    end
    if ok && (~isstruct(present) || ~any(strcmp(totest{1}, { present.extension })))
      p.name        = [ 'Compressed archive ' totest{1} ];
      p.extension   = totest{1};
      p.method      = mfilename;
      p.decompress  = totest{3};
      p.compress    = totest{4};
      if isstruct(present)
        present(end+1) = p;
      else
        present = p;
      end
    end
  end
