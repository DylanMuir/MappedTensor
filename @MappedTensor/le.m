function s = le(m1, m2, varargin)
% <=   Less than or equal.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(le(m,n))
% See also: le

if nargout
  s = binary(m1,m2, 'le', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'le', varargin{:}); % in-place operation
  s = m1;
end
