function [Descr, args, bytes] = private_load_pos(filename)
% PRIVATE_LOAD_POS Read Atom Probe Tomography defined written by e.g. Cameca LEAP instruments.
%   PRIVATE_LOAD_POS(filename)
%
% A POS file is a simple binary file (big endians) consisting of 4-byte 
%   IEEE float32s representing the x, y, and z position (in nm), and 
%   mass/charge (in amu) of every atom in a dataset. It is used by many 
%   atom probe groups and software packages and is the current de facto 
%   exchange method. The format is detailed in 
%   https://github.com/oscarbranson/apt-tools/blob/master/file-format-info.pdf

Descr=''; args = [];

% check Bytes: must be multiple of 4, float32
bytes = dir(filename);
if round(bytes.bytes/4/32) ~= bytes.bytes/4/32
  return;
end

Descr= 'Atom Probe Tomography / Cameca LEAP instruments';
args = {
  'Offset',         0, ...
  'Format',         'single', ...
  'MachineFormat',  'ieee-be', ...
  'Dimension' ,     [4 bytes.bytes/4/32 ]};

