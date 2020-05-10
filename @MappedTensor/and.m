function s = and(m1, m2, varargin)
% &  Logical AND.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(and(m,n))
% See also: and

if nargout
  s = binary(m1,m2, 'and', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'and', varargin{:}); % in-place operation
  s = m1;
end
