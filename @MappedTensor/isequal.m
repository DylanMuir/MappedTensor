function s = isequal(m1, m2, varargin)
% ISEQUAL True if arrays are numerically equal.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(isequal(m,n))
% See also: isequal

if nargout
  s = binary(m1,m2, 'isequal', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'isequal', varargin{:}); % in-place operation
  s = m1;
end
