function s = xor(m1, m2, varargin)
% XOR Logical EXCLUSIVE OR.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(xor(m,n))
% See also: xor

if nargout
  s = binary(m1,m2, 'xor', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'xor', varargin{:}); % in-place operation
  s = m1;
end
