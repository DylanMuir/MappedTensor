function s = eq(m1, m2, varargin)
% ==  Equal.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(eq(m,n))
% See also: eq

if nargout
  s = binary(m1,m2, 'eq', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'eq', varargin{:}); % in-place operation
  s = m1;
end
