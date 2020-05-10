function s = or(m1, m2, varargin)
% |   Logical OR.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(or(m,n))
% See also: or

if nargout
  s = binary(m1,m2, 'or', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'or', varargin{:}); % in-place operation
  s = m1;
end
