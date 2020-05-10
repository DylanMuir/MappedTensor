function s = rdivide(m1, m2, varargin)
% ./  Right array divide.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(rdivide(m,n))
% See also: rdivide

if nargout
  s = binary(m1,m2, 'rdivide', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'rdivide', varargin{:}); % in-place operation
  s = m1;
end
