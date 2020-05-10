function s = ldivide(m1, m2, varargin)
% .\  Left array divide.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(ldivide(m,n))
% See also: ldivide

if nargout
  s = binary(m1,m2, 'ldivide', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'ldivide', varargin{:}); % in-place operation
  s = m1;
end
