function s = mldivide(m1, m2, varargin)
% \   Backslash or left matrix divide.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(mldivide(m,n))
% See also: mldivide

if nargout
  s = binary(m1,m2, 'mldivide', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'mldivide', varargin{:}); % in-place operation
  s = m1;
end
