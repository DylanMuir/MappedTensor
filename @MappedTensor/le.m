function s = le(m1, m2, varargin)
% <=   Less than or equal. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(le(m,n))
% See also: le

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
