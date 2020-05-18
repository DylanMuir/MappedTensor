function [Descr, args, header] = private_load_nrrd(filename)
% PRIVATE_LOAD_NRRD Read NRRD Nearly Raw Raster Data.
%
% A NRRD file is a simple binary block, preceeded by a text header until an
% empty line.
%
% See http://teem.sourceforge.net/nrrd/format.html

Descr=''; args = [];

header = nrrdread(filename);


Descr= 'Nearly Raw Raster Data';
args = {
  'Offset',         header.Offset, ...
  'Format',         header.Format, ...
  'MachineFormat',  header.MachineFormat, ...
  'Dimension' ,     header.Dimension' };

% ------------------------------------------------------------------------------
% https://www.mathworks.com/matlabcentral/fileexchange/34653-nrrd-format-file-reader
% ------------------------------------------------------------------------------

%  Copyright (c) 2016, The MathWorks, Inc.
%  All rights reserved.

%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are met:

%  * Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.

%  * Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  * In all cases, the software is, and all modifications and derivatives of the
%    software shall be, licensed to you solely for use in conjunction with
%    MathWorks products and service offerings.

%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
%  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [meta] = nrrdread(filename)
%NRRDREAD  Import NRRD imagery and metadata.
%   [X, META] = NRRDREAD(FILENAME) reads the image volume and associated
%   metadata from the NRRD-format file specified by FILENAME.
%
%   Current limitations/caveats:
%   * "Block" datatype is not supported.
%   * Only tested with "gzip" and "raw" file encodings.
%   * Very limited testing on actual files.
%   * I only spent a couple minutes reading the NRRD spec.
%
%   See the format specification online:
%   http://teem.sourceforge.net/nrrd/format.html
% Copyright 2012 The MathWorks, Inc.
% Open file.
fid = fopen(filename, 'rb');
assert(fid > 0, 'Could not open file.');
cleaner = onCleanup(@() fclose(fid));
% Magic line.
theLine = fgetl(fid);
assert(numel(theLine) >= 4, 'Bad signature in file.')
assert(isequal(theLine(1:4), 'NRRD'), 'Bad signature in file.')
% The general format of a NRRD file (with attached header) is:
% 
%     NRRD000X
%     <field>: <desc>
%     <field>: <desc>
%     # <comment>
%     ...
%     <field>: <desc>
%     <key>:=<value>
%     <key>:=<value>
%     <key>:=<value>
%     # <comment>
% 
%     <data><data><data><data><data><data>...
meta = struct([]);
% Parse the file a line at a time.
while (true)
  theLine = fgetl(fid);
  
  if (isempty(theLine) || feof(fid))
    % End of the header.
    break;
  end
  
  if (isequal(theLine(1), '#'))
      % Comment line.
      continue;
  end
  
  % "fieldname:= value" or "fieldname: value" or "fieldname:value"
  parsedLine = regexp(theLine, ':=?\s*', 'split','once');
  
  assert(numel(parsedLine) == 2, 'Parsing error')
  
  field = lower(parsedLine{1});
  value = parsedLine{2};
  
  field(isspace(field)) = '';
  meta(1).(field) = value;
  
end
datatype = getDatatype(meta.type);
% Get the size of the data.
assert(isfield(meta, 'sizes') && ...
       isfield(meta, 'encoding') , ...
       'Missing required metadata fields.')
dims = sscanf(meta.sizes, '%d');
if isfield(meta,'dimension')
  ndims = sscanf(meta.dimension, '%d');
  assert(numel(dims) == ndims);
end
meta.Offset = ftell(fid);
%data = readData(fid, meta, datatype);
%data = adjustEndian(data, meta);
% Reshape and get into MATLAB's order.
meta.Dimension = dims;
%X = reshape(data, dims');
%X = permute(X, [2 1 3]);

% prepare for MappedTensor
meta.Format = datatype;
meta.MachineFormat = '';
if isfield(meta, 'endian')
  switch meta.endian
  case {'little','L','le'}
    meta.MachineFormat = 'ieee-le';
  case {'big','B','be'}
    meta.MachineFormat = 'ieee-be';
  end
end  

% ------------------------------------------------------------------------------

function datatype = getDatatype(metaType)
% Determine the datatype
switch (metaType)
 case {'signed char', 'int8', 'int8_t'}
  datatype = 'int8';
  
 case {'uchar', 'unsigned char', 'uint8', 'uint8_t'}
  datatype = 'uint8';
 case {'short', 'short int', 'signed short', 'signed short int', ...
       'int16', 'int16_t'}
  datatype = 'int16';
  
 case {'ushort', 'unsigned short', 'unsigned short int', 'uint16', ...
       'uint16_t'}
  datatype = 'uint16';
  
 case {'int', 'signed int', 'int32', 'int32_t'}
  datatype = 'int32';
  
 case {'uint', 'unsigned int', 'uint32', 'uint32_t'}
  datatype = 'uint32';
  
 case {'longlong', 'long long', 'long long int', 'signed long long', ...
       'signed long long int', 'int64', 'int64_t'}
  datatype = 'int64';
  
 case {'ulonglong', 'unsigned long long', 'unsigned long long int', ...
       'uint64', 'uint64_t'}
  datatype = 'uint64';
  
 case {'float'}
  datatype = 'single';
  
 case {'double'}
  datatype = 'double';
  
 otherwise
  assert(false, 'Unknown datatype')
end


function data = readData(fidIn, meta, datatype)
switch (meta.encoding)
 case {'raw'}
  
  data = fread(fidIn, inf, [datatype '=>' datatype]);
  
 case {'gzip', 'gz'}
  tmpBase = tempname();
  tmpFile = [tmpBase '.gz'];
  fidTmp = fopen(tmpFile, 'wb');
  assert(fidTmp > 3, 'Could not open temporary file for GZIP decompression')
  
  tmp = fread(fidIn, inf, 'uint8=>uint8');
  fwrite(fidTmp, tmp, 'uint8');
  fclose(fidTmp);
  
  gunzip(tmpFile)
  
  fidTmp = fopen(tmpBase, 'rb');
  cleaner = onCleanup(@() fclose(fidTmp));
  
  meta.encoding = 'raw';
  data = readData(fidTmp, meta, datatype);
  
 case {'txt', 'text', 'ascii'}
  
  data = fscanf(fidIn, '%f');
  data = cast(data, datatype);
  
 otherwise
  assert(false, 'Unsupported encoding')
end


function data = adjustEndian(data, meta)
if ~isfield(meta, 'endian'), return; end
[~,~,endian] = computer();
needToSwap = (isequal(endian, 'B') && isequal(lower(meta.endian), 'little')) || ...
             (isequal(endian, 'L') && isequal(lower(meta.endian), 'big'));
         
if (needToSwap)
    data = swapbytes(data);
end
