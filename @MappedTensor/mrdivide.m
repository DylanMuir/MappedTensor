function s = mrdivide(m1, m2, varargin)
% /   Slash or right matrix divide.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(mrdivide(m,n))
% See also: mrdivide

if nargout
  s = binary(m1,m2, 'mrdivide', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'mrdivide', varargin{:}); % in-place operation
  s = m1;
end
