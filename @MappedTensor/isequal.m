function s = isequal(m1, m2, varargin)
% ISEQUAL True if arrays are numerically equal. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=copyobj(m); tf=isequal(m,n)
% See also: isequal

s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
