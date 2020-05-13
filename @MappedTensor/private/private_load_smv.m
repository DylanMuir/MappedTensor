function [Descr, args, frame] = private_load_smv(filename)
% PRIVATE_LOAD_SMV read an ADSC X-ray detector image
%
%  Read an image file written by an ADSC detector.
%  ADSC detectors write images in the "SMV" file format which consists of a text
%     header and uncompressed image.
%  ADSC_read takes the file 'fname' and returns text header in 'header'.
%
%  A typical header begins,
%               {
%               HEADER_BYTES=  512;
%               DIM=2;
%               BYTE_ORDER=little_endian;
%               TYPE=unsigned_short;
%               SIZE1=1152;
%               SIZE2=1152;
%               PIXEL_SIZE=0.0816; ...
%
%  From this one can rapidly determine,
%               a)  The header is a 512 bytes long.
%               b)  512 bytes into the file, the image is stored as a set of SIZE1*SIZE2 unsigned_short integers.
%
%   ADSC_read   determines the size of the header, 
%               places the header info in 'header',
%               determines the image size,
%               places the image in imag.
%
%   At present ADSC_read has very little consistency checking.
%   Furthermore, at present we assume the image consists of unsigned 16-bit integers.
%   However, it should at least return the first Nmin=512 bytes of the file in header.
%
% References:
%   GEST - August 7, 2004. Gil Toombes, get1 _ at _ cornell.edu 
%   adsc_read by Gil Toombes, 2004
%   used to import ADSC X-ray CCD image, no license
%   <http://bigbro.biophys.cornell.edu/~toombes/Software/ADSC_Detectors_Using_Spec/>
%   <http://www.adsc-xray.com/products.html>

Descr=''; args = {}; frame = [];

% read the header
fid = fopen(filename,'r'); 

% Scan in at least the first part of the header to determine the header size.
Nmin = 512;
temp = fread(fid,Nmin,'uchar=>char'); temp=temp'; header = temp;
spos = strfind(temp,'HEADER_BYTES');
Nbytes = sscanf(temp([spos:Nmin]),'HEADER_BYTES=%d');
if isempty(Nbytes)
  disp([ mfilename ': ' filename ' is not an ADSC image.' ])
  fclose(fid);
  return
end

% Read in the whole header
fseek(fid,0,-1);
header = fread(fid,Nbytes,'uchar=>char'); header=header';

% check if the header looks consistent
test = isstrprop(header,'print') | isstrprop(header, 'wspace');
if all(test)
  % Determine image size
  temp = max(strfind(header,'SIZE1'));
  Xsize = sscanf(header([temp:Nbytes]),'SIZE1=%d');
  temp = max(strfind(header,'SIZE2'));
  Ysize = sscanf(header([temp:Nbytes]),'SIZE2=%d');

  frame = str2struct(header);
  frame.Offset    = ftell(fid);
  frame.Dimension = [Xsize, Ysize];
  frame.Format    = 'uint16';
else
  disp([ mfilename ': ' filename ' does not begin with a 512 byte text header.' ]);
  fclose(fid);
  return;
end

Descr = 'ADSC CCD Camera';
args = { ...
  'Offset',         frame.Offset, ...
  'Format',         frame.Format, ...
  'Dimension',      frame.Dimension };

