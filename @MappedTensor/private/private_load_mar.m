function [Descr, args, frame] = private_load_mar(filename)
% PRIVATE_LOAD_MAR Read a MAR CCD image
%
% Description:
% Macro for reading TIFF files written by a MAR CCD
%
% References:
%   July 17th 2008, Oliver Bunk: 1st version
%   <http://www.psi.ch/sls/csaxs/software>

% Note:
% MAR data are TIFF and can be read by forcing the type to tif. 
% The advantage of forcing the type to mar is, that additional header 
% fields like the exposure time are read. 
% This follows the MarCCD header documentaion by Blum and Doyle
% marccd v0.17.1

Descr=''; args = {}; frame = [];

% read header ------------------------------------------------------------------
% read all data at once
fid = fopen(filename);
[fdat,fcount] = fread(fid,4096,'uint8=>uint8');
fclose(fid);

% the MAR header has a fixed length of 1024 bytes for the TIFF header plus
% 3072 bytes for the MAR specific part
end_of_header_pos = 4096;

if (length(fdat) < end_of_header_pos)
    disp([ mfilename ': Not a MAR CCD file: ' num2str(length(fdat)) ...
      ' bytes read, which is less than the constant header length.' ]);
    return
end

% check little/big endian, also to recognize MAR files
if (typecast(fdat(1025+32:1025+35),'uint32') ~= 1234)
  disp([ mfilename ': ' filename ' is not a MAR file or has big endian byte order.' ]);
  return
end

% get image dimensions
nfast = typecast(fdat(1025+80:1025+83),'uint32');
nslow = typecast(fdat(1025+84:1025+87),'uint32');
bytes_per_pixel = typecast(fdat(1025+88:1025+91),'uint32');

if ((bytes_per_pixel ~= 2) && (bytes_per_pixel ~= 4))
    disp( [ mfilename ': unforseen no. of bytes per pixel of ' num2str(bytes_per_pixel) ] );
    return
end

% return some selected header fields as lines of a cell array
frame.header.IntegrationTime_ms = typecast(fdat(1025+640+12:1025+640+15),'uint32');
frame.header.ExposureTime_ms    = typecast(fdat(1025+640+16:1025+640+19),'uint32');
frame.header.ReadoutTime_ms     = typecast(fdat(1025+640+20:1025+640+23),'uint32');
frame.header.nReads             = typecast(fdat(1025+640+24:1025+640+27),'uint32');
frame.header.Date               = sprintf('%s %s %s:%s%s %s',...
    char(fdat(2369:2370)'),...
    char(fdat(2371:2372)'),...
    char(fdat(2373:2374)'),...
    char(fdat(2375:2376)'),...
    char(fdat(2381:2383)'),...
    char(fdat(2377:2380)'));
frame.header.PixelSizeX_nm      = typecast(fdat(1025+768+4:1025+768+7),'uint32');
frame.header.PixelSizeY_nm      = typecast(fdat(1025+768+8:1025+768+11),'uint32');

frame.MachineFormat = 'ieee-le';
frame.Offset = 4096;


% store data
switch bytes_per_pixel
case 2
  frame.Format = 'uint16';
case 4
  frame.Format = 'uint32';
otherwise
  disp( [ mfilename ': unforseen no. of bytes per pixel of ' num2str(bytes_per_pixel) ] );
  return
end
frame.Dimension = [ nfast nslow ];

Descr = 'MAR CCD image';
args = { ...
  'Offset',         frame.Offset, ...
  'Format',         frame.Format, ...
  'MachineFormat',  frame.MachineFormat, ...
  'Dimension',      frame.Dimension };

