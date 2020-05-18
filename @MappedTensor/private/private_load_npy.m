function [Descr,args,s] = private_load_npy(filename)
% PRIVATE_LOAD_NPY Reads a single NumPy array (binary format).
%   Read a Python Numpy array '.npy' file.
%   can handle: 'uint8','uint16','uint32','uint64
%               'int8','int16','int32','int64'
%               'single','double', 'logical'
%
%   To generate a NPY file, use python:
%   >>> import numpy as np
%   >>> x = np.arange(10)
%   >>> np.save('outfile.npy', x)
%
% References:
% format specification: https://docs.scipy.org/doc/numpy/neps/npy-format.html
% contrib: https://github.com/kwikteam/npy-matlab, C. Rossant 2016


Descr=''; args = {};

% check header (see inline below)
[s.shape, s.dataType, s.fortranOrder, s.littleEndian, s.totalHeaderLength, s.npyVersion] = readNPYheader(filename);
if isempty(s.shape), s=[]; return; end

Descr  = 'Python NumPy array';
Offset = s.totalHeaderLength;
Format = s.dataType;
if s.littleEndian
  MachineFormat = 'ieee-le';
else
  MachineFormat = 'ieee-be';
end

if length(s.shape)>1 && ~s.fortranOrder
  Dimension = s.shape(end:-1:1);
  Dimension = Dimension([length(s.shape):-1:1]);
elseif length(s.shape)>1
  Dimension = s.shape;
else
  Dimension = [ s.shape 1 ];
end

args = { ...
  'Offset',         Offset, ...
  'Format',         Format, ...
  'MachineFormat',  MachineFormat, ...
  'Dimension',      Dimension };

% ------------------------------------------------------------------------------
function [arrayShape, dataType, fortranOrder, littleEndian, totalHeaderLength, npyVersion] = readNPYheader(filename)
% function [arrayShape, dataType, fortranOrder, littleEndian, ...
%       totalHeaderLength, npyVersion] = readNPYheader(filename)
%
% parse the header of a .npy file and return all the info contained
% therein.
%
% Based on spec at http://docs.scipy.org/doc/numpy-dev/neps/npy-format.html

arrayShape=[]; dataType=[]; fortranOrder=[]; littleEndian=[]; totalHeaderLength=[]; npyVersion=[];
fid = fopen(filename);

% verify that the file exists
if (fid == -1)
    if ~isempty(dir(filename))
        fprintf(1,'Permission denied: %s', filename);
    else
        fprintf(1,'File not found: %s', filename);
    end
end

try
    
    dtypesMatlab = {'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double', 'logical'};
    dtypesNPY = {'u1', 'u2', 'u4', 'u8', 'i1', 'i2', 'i4', 'i8', 'f4', 'f8', 'b1'};
    
    
    magicString = fread(fid, [1 6], 'char=>char');
    
    if ~strcmp(magicString, '�NUMPY')
        disp('Warning: This file does not appear to be NUMPY format (based on the header).');
    end
    
    majorVersion = fread(fid, [1 1], 'uint8=>uint8');
    minorVersion = fread(fid, [1 1], 'uint8=>uint8');
    
    npyVersion = [majorVersion minorVersion];
    
    headerLength = fread(fid, [1 1], 'uint16=>unit16');
    
    totalHeaderLength = 10+headerLength;
    
    arrayFormat = fread(fid, [1 headerLength], 'char=>char');
    
    % to interpret the array format info, we make some fairly strict
    % assumptions about its format...
    
    r = regexp(arrayFormat, '''descr''\s*:\s*''(.*?)''', 'tokens');
    dtNPY = r{1}{1};    
    
    littleEndian = ~strcmp(dtNPY(1), '>');
    
    dataType = dtypesMatlab{strcmp(dtNPY(2:3), dtypesNPY)};
        
    r = regexp(arrayFormat, '''fortran_order''\s*:\s*(\w+)', 'tokens');
    fortranOrder = strcmp(r{1}{1}, 'True');
    
    r = regexp(arrayFormat, '''shape''\s*:\s*\((.*?)\)', 'tokens');
    shapeStr = r{1}{1}; 
    arrayShape = str2num(shapeStr(shapeStr~='L'));

    
    fclose(fid);
    
catch me
    fclose(fid);
    rethrow(me);
end

