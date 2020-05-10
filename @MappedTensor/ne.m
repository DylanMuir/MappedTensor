function s = ne(m1, m2, varargin)
% ~=  Not equal.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(ne(m,n))
% See also: ne

if nargout
  s = binary(m1,m2, 'ne', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'ne', varargin{:}); % in-place operation
  s = m1;
end
