function [Descr, args, Data] = private_load_mrc(filename)
% PRIVATE_LOAD_MRC MRC/CCP4/MAP electronic density map file.
%
% Format definition:
% <http://en.wikipedia.org/wiki/MRC_%28file_format%29>
%
% Get EM data files at EMDB Data base <https://www.emdataresource.org/index.html>
%
% References:
% tom_mrcread from Wolfgang Baumeister (TOM Matlab toolbox), 2008
%  used to read MRC electron density map files
%  <http://www.biochem.mpg.de/en/rd/baumeister/tom_e/>

Descr=''; args = {}; Data = [];

% first try as a legacy MRC file
Data = tom_mrcread(filename);       % inline below

% then try as a CCP4/MRC 2000
if isempty(Data)
  Data = ccp4_read(filename);       % inline below
end
if isempty(Data), return; end

Descr = 'MRC/CCP4/MAP electronic density map';
args = { ...
  'Offset',         Data.Offset, ...
  'Format',         Data.Format, ...
  'MachineFormat',  Data.MachineFormat, ...
  'Dimension',      Data.Dimension };



% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
function Data = tom_mrcread(mrc_name)
%TOM_MRCREAD reads MRC format file
%
%   tom_mrcread(varargin)
%
%
%
%   Reads a 2D or 3D MRC format file. A MRC format contains a 1024 Bytes
%   header and the raw data. If there is no input then a dialog box appears to
%   select a file. Endian is an option, 'le' for little-endian (PC), 'be' for
%   big-endian (SGI,MAC)
%
%PARAMETERS
%
%  INPUT
%   varargin{1} 	   filename
%   varargin{2} 	   endian
%
%
%  OUTPUT
%   data	datamatrix
%
%Structure of MRC-data files:
%MRC Header has a length of 1024 bytes
% ID SIZE  DATA	NAME	DESCRIPTION
% 1   4	int	NX	number of Columns    (fastest changing in map)
% 2   4	int	NY	number of Rows
% 3   4	int	NZ	number of Sections   (slowest changing in map)
% 4   4	int	MODE	Types of pixel in image
%			0 = Image     unsigned bytes
%			1 = Image     signed short integer (16 bits)
%			2 = Image     float
%			3 = Complex   short*2
%			4 = Complex   float*2
% 5   4 int	NXSTART Number of first COLUMN  in map (Default = 0)
% 6   4	int	NYSTART Number of first ROW	in map      "
% 7   4	int	NZSTART Number of first SECTION in map      "
% 8   4	int	MX	Number of intervals along X
% 9   4	int	MY	Number of intervals along Y
% 10  4	int	MZ	Number of intervals along Z
% 11  4	float	Xlen	Cell Dimensions (Angstroms)
% 12  4	float	Ylen		     "
% 13  4	float	Zlen		     "
% 14  4	float	ALPHA	Cell Angles (Degrees)
% 15  4	float	BETA		     "
% 16  4	float	GAMMA		     "
% 17  4	int	MAPC	Which axis corresponds to Columns  (1,2,3 for X,Y,Z)
% 18  4	int	MAPR	Which axis corresponds to Rows     (1,2,3 for X,Y,Z)
% 19  4	int	MAPS	Which axis corresponds to Sections (1,2,3 for X,Y,Z)
% 20  4	float	AMIN	Minimum density value
% 21  4	float	AMAX	Maximum density value
% 22  4	float	AMEAN	Mean	density value	 (Average)
% 23  2	short	ISPG	Space group number	 (0 for images)
%     2	short	NSYMBT  Number of bytes used for storing symmetry operators
% 24  4	int	NEXT	Number of bytes in extended header
% 25  2	short	CREATID Creator ID
%     30    -	EXTRA	Not used. All set to zero by default
% 33  2	short	NINT	Number of integer per section
%     2	short	NREAL	Number of reals per section
% 34  28    -	EXTRA2  Not used. All set to zero by default
% 41  2	short	IDTYPE  0=mono, 1=tilt, 2=tilts, 3=lina, 4=lins
%     2	short	LENS
% 42  2	short	ND1
%     2	short	ND2
% 43  2	short	VD1
%     2	short	VD2
% 44  24  float	TILTANGLES
% 50  4	float	XORIGIN X origin
% 51  4	float	YORIGIN Y origin
% 52  4	float	ZORIGIN Z origin
% 53  4	char	CMAP	Contains "MAP "
% 54  4	char	STAMP
% 55  4	float	RMS
% 56  4	int	NLABL	Number of labels being used
% 57  800 char	10 labels of 80 character
%
%Extended Header (FEI format and IMOD format)
%The extended header contains the information about a maximum of 1024 images.
%Each section is 128 bytes long. The extended header is thus 1024 * 128 bytes
%(always the same length, regardless of how many images are present
%   4	float	a_tilt  Alpha tilt (deg)
%   4	float	b_tilt  Beta tilt (deg)
%   4	float	x_stage  Stage x position (Unit=m. But if value>1, unit=???m)
%   4	float	y_stage  Stage y position (Unit=m. But if value>1, unit=???m)
%   4	float	z_stage  Stage z position (Unit=m. But if value>1, unit=???m)
%   4	float	x_shift  Image shift x (Unit=m. But if value>1, unit=???m)
%   4	float	y_shift  Image shift y (Unit=m. But if value>1, unit=???m)
%   4	float	z_shift  Image shift z (Unit=m. But if value>1, unit=???m)
%   4	float	defocus  Defocus Unit=m. But if value>1, unit=???m)
%   4	float	exp_time Exposure time (s)
%   4	float	mean_int Mean value of image
%   4	float	tilt_axis   Tilt axis (deg)
%   4	float	pixel_size  Pixel size of image (m)
%   4	float	magnification	Magnification used
%   4	float	remainder   Not used (filling up to 128 bytes)
%
%EXAMPLE
%   A fileselect-box appears and the EM-file can be picked
%   i=tom_mrcread
%
% im=tom_mrcread('20S_core_1.6nm.mrc');
% figure; tom_dspcub(im.Value);
%
%REFERENCES
%
%SEE ALSO
%   TOM_EMREAD, TOM_SPIDERREAD, TOM_ISMRCFILE, TOM_MRCWRITE, TOM_MRC2EM
%
%   created by SN 09/25/02
%   updated by WDN 06/22/05
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom
%
Data = [];

%error(nargchk(0,2,nargin))
[comp_typ,maxsize,endian] = computer;
switch endian
case 'le'
	sysfor='ieee-le';
case 'L'
	sysfor='ieee-le';
case 'be'
	sysfor='ieee-be';
case 'B'
	sysfor='ieee-be';
end

% read HEADER
fid = fopen(mrc_name,'r',sysfor);
MRC.nx = fread(fid,[1],'int');        %integer: 4 bytes
MRC.ny = fread(fid,[1],'int');        %integer: 4 bytes
MRC.nz = fread(fid,[1],'int');        %integer: 4 bytes
MRC.mode = fread(fid,[1],'int');      %integer: 4 bytes
if MRC.mode > 5 || MRC.mode < 0
  fprintf([ mfilename ': wrong MODE=%i (MRC)\n' ], MRC.mode);
  fclose(fid);
  return;
end
MRC.nxstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nystart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nzstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.mx= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.my= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.mz= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.xlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.ylen= fread(fid,[1],'float');     %float: 4 bytes
MRC.zlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.alpha= fread(fid,[1],'float');    %float: 4 bytes
MRC.beta= fread(fid,[1],'float');     %float: 4 bytes
MRC.gamma= fread(fid,[1],'float');    %float: 4 bytes
MRC.mapc= fread(fid,[1],'long');       %integer: 4 bytes
MRC.mapr= fread(fid,[1],'long');       %integer: 4 bytes
MRC.maps= fread(fid,[1],'long');       %integer: 4 bytes
MRC.amin= fread(fid,[1],'float');     %float: 4 bytes
MRC.amax= fread(fid,[1],'float');     %float: 4 bytes
MRC.amean= fread(fid,[1],'float');    %float: 4 bytes
MRC.ispg= fread(fid,[1],'short');     %integer: 2 bytes #23
MRC.nsymbt = fread(fid,[1],'short');  %integer: 2 bytes
MRC.next = fread(fid,[1],'int');      %integer: 4 bytes
MRC.creatid = fread(fid,[1],'short'); %integer: 2 bytes
MRC.unused1 = fread(fid,[30]);        %not used: 30 bytes
MRC.nint = fread(fid,[1],'short');    %integer: 2 bytes
MRC.nreal = fread(fid,[1],'short');   %integer: 2 bytes
MRC.unused2 = fread(fid,[28]);        %not used: 28 bytes
MRC.idtype= fread(fid,[1],'short');   %integer: 2 bytes
if MRC.idtype > 4 || MRC.idtype < 0
  fprintf([ mfilename ': wrong IDTYPE=%i\n' ], MRC.idtype);
  fclose(fid);
  return
end
MRC.lens=fread(fid,[1],'short');      %integer: 2 bytes
MRC.nd1=fread(fid,[1],'short');       %integer: 2 bytes
MRC.nd2 = fread(fid,[1],'short');     %integer: 2 bytes
MRC.vd1 = fread(fid,[1],'short');     %integer: 2 bytes
MRC.vd2 = fread(fid,[1],'short');     %integer: 2 bytes
for i=1:6			      %24 bytes in total
    MRC.tiltangles(i)=fread(fid,[1],'float');%float: 4 bytes
end
MRC.xorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.yorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.zorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.cmap = fread(fid,[4],'uint8=>char');     %Character: 4 bytes # 53
if ~strncmp(MRC.cmap, 'MAP',3)
  fprintf([ mfilename ': wrong CMAP token=%s\n' ], MRC.cmap);
  fclose(fid);
  return; % not an MRC file
end
MRC.stamp = fread(fid,[4],'char');    %Character: 4 bytes
MRC.rms   = fread(fid,[1],'float');       %float: 4 bytes
MRC.nlabl = fread(fid,[1],'int');     %integer: 4 bytes
MRC.labl  = fread(fid,[800],'uint8=>char');   %Character: 800 bytes
MRC.labl  = strtrim(deblank(regexprep(MRC.labl(:)','\s{2,}',' ')));

if MRC.mode==0
    beval=MRC.nx*MRC.ny*MRC.nz;
    Data_read = zeros(MRC.nx,MRC.ny,MRC.nz,'int8');
elseif MRC.mode==1
    beval=MRC.nx*MRC.ny*MRC.nz*2;
    Data_read = zeros(MRC.nx,MRC.ny,MRC.nz,'int16');
elseif MRC.mode==2
    beval=MRC.nx*MRC.ny*MRC.nz*4;
    Data_read = zeros(MRC.nx,MRC.ny,MRC.nz,'single');
end
Extended.magnification(1)=0;
Extended.exp_time(1)=0;
Extended.pixelsize(1)=0;
Extended.defocus(1)=0;
Extended.a_tilt(1:MRC.nz)=0;
Extended.tiltaxis(1)=0;
if MRC.next~=0%Extended Header
    nbh=MRC.next./128;%128=lengh of FEI extended header
    if nbh==1024%FEI extended Header
	    for lauf=1:nbh
	        Extended.a_tilt(lauf)= fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.b_tilt(lauf)= fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.x_stage(lauf)= fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.y_stage(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.z_stage(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.x_shift(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.y_shift(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.defocus(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.exp_time(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.mean_int(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.tiltaxis(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.pixelsize(lauf)=fread(fid,[1],'float');	  %float: 4 bytes
	        Extended.magnification(lauf)=fread(fid,[1],'float');  %float: 4 bytes
	        fseek(fid,128-52,0);
	        %position = ftell(fid)
	    end
    else %IMOD extended Header
      fseek(fid,MRC.next,'cof');%go to end end of extended Header
    end
end

if MRC.mode==0
  %fseek(fid,-beval,0); %go to the beginning of the values
  %Data_read(:,:,i) = fread(fid,[MRC.nx,MRC.ny],'int8');
  Data.Format = 'int8';
elseif MRC.mode==1
  Data.Format = 'int16';
elseif MRC.mode==2
  Data.Format = 'single';
else
  disp([ mfilename ': Invalid MRC content.' ]);
  return
end

% now we are to read the data
Data.Offset        = ftell(fid);
fclose(fid);
Data.Dimension     = [MRC.nx,MRC.ny, MRC.nz];
Data.MachineFormat = sysfor;

Header=struct(...
    'Voltage',0,...
    'Cs',0,...
    'Aperture',0,...
    'Magnification',Extended.magnification(1),...
    'Postmagnification',0,...
    'Exposuretime',Extended.exp_time(1),...
    'Objectpixelsize',Extended.pixelsize(1).*1e9,...
    'Microscope',0,...
    'Pixelsize',0,...
    'CCDArea',0,...
    'Defocus',Extended.defocus(1),...
    'Astigmatism',0,...
    'AstigmatismAngle',0,...
    'FocusIncrement',0,...
    'CountsPerElectron',0,...
    'Intensity',0,...
    'EnergySlitwidth',0,...
    'EnergyOffset',0,... 
    'Tiltangle',Extended.a_tilt(1:MRC.nz),...
    'Tiltaxis',Extended.tiltaxis(1),...
    'Username',num2str(zeros(20,1)),...
    'Date',num2str(zeros(8)),...
    'Size',[MRC.nx,MRC.ny,MRC.nz],...
    'Comment',num2str(zeros(80,1)),...
    'Parameter',num2str(zeros(40,1)),...
    'Fillup',num2str(zeros(256,1)),...
    'Filename',mrc_name,...
    'Marker_X',0,...
    'Marker_Y',0,...
    'MRC',MRC);

Data.Header= Header; % contains MRC
Data.Title = MRC.labl;
% Data.Format='MRC electron density map';
Data.MRC = MRC;
Data.Extended = Extended;


% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------

function Data = ccp4_read(file)
% read CCP4 format file
%
% Read an MRC 2000/ccp4 format file.
%
% Header contains four byte integer or float values:
%
% 1        NX        number of columns (fastest changing in map)        
% 2        NY        number of rows                                        
% 3        NZ        number of sections (slowest changing in map)        
% 4        MODE        data type :                                        
%                 0        image : signed 8-bit bytes range -128 to 127
%                 1        image : 16-bit halfwords                
%                 2        image : 32-bit reals                        
%                 3        transform : complex 16-bit integers        
%                 4        transform : complex 32-bit reals        
% 5        NXSTART        number of first column in map                        
% 6        NYSTART        number of first row in map                        
% 7        NZSTART        number of first section in map                        
% 8        MX        number of intervals along X                        
% 9        MY        number of intervals along Y                        
% 10        MZ        number of intervals along Z                        
% 11-13        CELLA        cell dimensions in angstroms                        
% 14-16        CELLB        cell angles in degrees                                
% 17        MAP% axis corresp to cols (1,2,3 for X,Y,Z)                
% 18        MAPR        axis corresp to rows (1,2,3 for X,Y,Z)                
% 19        MAPS        axis corresp to sections (1,2,3 for X,Y,Z)        
% 20        DMIN        minimum density value                                
% 21        DMAX        maximum density value                                
% 22        DMEAN        mean density value                                
% 23        ISPG        space group number 0 or 1 (default=0)                
% 24        NSYMBT        number of bytes used for symmetry data (0 or 80)
% 25-49   EXTRA        extra space used for anything                        
% 50-52        ORIGIN  origin in X,Y,Z used for transforms                
% 53        MAP        character string 'MAP ' to identify file type        
% 54        MACHST        machine stamp                                        
% 55        RMS        rms deviation of map from mean density                
% 56        NLABL        number of labels being used                        
% 57-256 LABEL(20,10) 10 80-character text labels     

Data = [];

[comp_typ,maxsize,endian] = computer;
switch endian
case {'le','L'}
	sysfor='ieee-le';
case {'be','B'}
	sysfor='ieee-be';
end

fid = fopen(file,'r',sysfor);

MRC.nx = fread(fid,[1],'int');        %integer: 4 bytes
MRC.ny = fread(fid,[1],'int');        %integer: 4 bytes
MRC.nz = fread(fid,[1],'int');        %integer: 4 bytes
MRC.mode = fread(fid,[1],'int');      %integer: 4 bytes
if MRC.mode > 5 || MRC.mode < 0
  fprintf([ mfilename ': wrong MODE=%i (CCP4)\n' ], MRC.mode);
  fclose(fid);
  return;
end
MRC.nxstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nystart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nzstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.mx= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.my= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.mz= fread(fid,[1],'int');	      %integer: 4 bytes
MRC.xlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.ylen= fread(fid,[1],'float');     %float: 4 bytes
MRC.zlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.alpha= fread(fid,[1],'float');    %float: 4 bytes
MRC.beta= fread(fid,[1],'float');     %float: 4 bytes
MRC.gamma= fread(fid,[1],'float');    %float: 4 bytes
MRC.mapc= fread(fid,[1],'int');       %integer: 4 bytes
MRC.mapr= fread(fid,[1],'int');       %integer: 4 bytes
MRC.maps= fread(fid,[1],'int');       %integer: 4 bytes
MRC.amin= fread(fid,[1],'float');     %float: 4 bytes
MRC.amax= fread(fid,[1],'float');     %float: 4 bytes
MRC.amean= fread(fid,[1],'float');    %float: 4 bytes
MRC.ispg= fread(fid,[1],'int');     %integer: 4 bytes #23
MRC.nsymbt = fread(fid,[1],'int');     %integer: 4 bytes
MRC.extra = fread(fid,[26],'int');     %integer: 4*26 bytes
MRC.xorigin = fread(fid,[1],'int');     %float: 4 bytes #50
MRC.yorigin = fread(fid,[1],'int');     %float: 4 bytes
MRC.zorigin = fread(fid,[1],'int');     %float: 4 bytes
MRC.cmap = fread(fid,[4],'uint8=>char');     %Character: 4 bytes # 53
if ~strncmp(MRC.cmap, 'MAP',3)
  fprintf([ mfilename ': wrong CMAP token=%s\n' ], MRC.cmap);
  fclose(fid);
  return; % not an MRC file
end
MRC.stamp = fread(fid,[4],'char');    %Character: 4 bytes
MRC.rms   = fread(fid,[1],'float');       %float: 4 bytes
MRC.nlabl = fread(fid,[1],'int');     %integer: 4 bytes
MRC.labl  = fread(fid,[800],'uint8=>char');   %Character: 800 bytes
MRC.labl  = strtrim(deblank(regexprep(MRC.labl(:)','\s{2,}',' ')));

if MRC.mode==0
  Data.Format = 'int8';
elseif MRC.mode==1
  Data.Format = 'int16';
elseif MRC.mode==2
  Data.Format = 'single';
else
  disp([ mfilename ': Invalid MRC content.' ]);
  return
end

% now we are to read the data
Data.Offset        = ftell(fid);
fclose(fid);
Data.Dimension     = [MRC.nx,MRC.ny, MRC.nz];
Data.MachineFormat = sysfor;
Data.Title = MRC.labl;
Data.Header= MRC;
% Data.Format='CCP4 electron density map'; 

