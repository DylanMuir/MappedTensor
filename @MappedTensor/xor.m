function s = xor(m1, m2, varargin)
% XOR Logical EXCLUSIVE OR. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(xor(m,n))
% See also: xor

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
