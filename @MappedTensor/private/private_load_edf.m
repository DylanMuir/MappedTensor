function [Descr, args, header] = private_load_edf(filename)
% PRIVATE_LOAD_EDF Read an ESRF Data Format file (EDF)
%
% Only reads the first block/image
%
% Using: pmedf_read and pmedfwrite by Petr Mikulik, Masaryk University, Brno, 11.8.2010
%  <http://www.sci.muni.cz/~mikulik/Soft4Synchro.html>

Descr=''; args = {}; frame = [];

header = pmedf_read ( filename );
if isempty(header) || ~isfield(header,'Format'), return; end

Descr = 'ESRF Data Format';
args = { ...
  'Offset',         header.Offset, ...
  'Format',         header.Format, ...
  'MachineFormat',  header.MachineFormat, ...
  'Dimension',      header.Dimension };

% ------------------------------------------------------------------------------

%% Reading ESRF header files: .ehf / .edf files.
%%
%% Usage:
%%	[header, data] = pmedf_read('hello.edf');
%%	header = pmedf_read('hello.edf');
%%
%% The first syntax reads both the header and the data; the second one reads
%% only the header, which can be useful for parsing header information.
%%
%% Author: Petr Mikulik
%% Version: 31. 5. 2010
%% History:
%%	    May 2010:
%%		Report an error under Matlab if reading .gz/.bz2 data.
%%	    May 2008:
%%		Minor clean-up.
%%	    June 2006:
%%		Use the C++ plugin pmedf_readC if it exists; it is several
%%		times faster. (Currently (Octave up to 2.1.72) has slow fread()
%%		function for skip=0.)
%%	    February 2005:
%%		Don't read the data if only the header output argument requested.
%%		Better protection against files with a broken header.
%%		Added reading .gz and .bz2 files.
%%		Reread file if data not fully read (was happening with pipe).
%%	    September 2004:
%%		if (0) and warning for fscanf('%c') by Octave >=2.1.55.
%%	    May 2002:
%%		Rewrite into a new routine pmedf_read(); this one does not
%%		return a structure of keywords, but the whole header. This may
%%		be redefined, later?
%%	    2001:
%%		pmehf_read updated to read ID19 EDF files.
%%	    April 2000:
%%		pmehf_read.m for EHF files at ID1.

% Copyright (C) 2010 Petr Mikulik
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. 
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
% USA.

function edf = pmedf_read ( f )

header=[];  

[fid, msg] = fopen(f,'rb');

% read the header
hsize = 512; % edf header size is a multiple of 512
closing = sprintf('}\n');
[tmp, count] = fread(fid, 512, 'char');
header = sprintf('%c', tmp);

% check if this an EDF file
if isempty(strfind(header,'DataType')) || isempty(strfind(header,'ByteOrder')) ...
|| isempty(strfind(header, 'Size')) || isempty(strfind(header, 'Dim_1'))
  disp([ mfilename ': ' f ' is probably not an EDF file.' ])
  fclose(fid);
  return
end

while ~strcmp(header(length(header)-length(closing)+1:length(header)), closing)

  [tmp, count] = fread(fid, 512, 'char');
  header = [header, sprintf('%c', tmp)];
	if count<512 % this is not an edf file
	    header = [];
	    data = [];
	    disp([ mfilename ': ' f ' is probably not an EDF file.' ])
      fclose(fid);
	    return; 
	end
end

edf = str2struct(header);
edf.Offset = ftell(fid);
fclose(fid);

% handle more stuff in header
switch strtrim(edf.DataType)
case {'UnsignedInteger', 'UnsignedLong'}, dt='uint32'; 
case 'UnsignedShort', dt='uint16'; 
case 'UnsignedByte', dt='uint8'; 
case {'SignedInteger', 'SignedLong', 'Integer'}, dt='int32'; 
case {'SignedShort', 'Short'}, dt='int16'; 
case 'SignedByte', dt='int8'; 
case {'Float', 'FloatValue'}, dt='single'; 
case {'Double', 'DoubleValue'}, dt='double'; 
otherwise 
  disp(['Unknown data type "', edf.DataType, '" of file "', f, '"']);
  return
end
edf.Format = dt;

switch strtrim(edf.ByteOrder)
case 'HighByteFirst', edf.MachineFormat='ieee-be';
case 'LowByteFirst',  edf.MachineFormat='ieee-le';
otherwise edf.MachineFormat='';
end

edf.Dimension = [ edf.Dim_1 edf.Dim_2 ];
