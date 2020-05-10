function s = minus(m1, m2, varargin)
% -   Minus.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(minus(m,n))
% See also: minus

if nargout
  s = binary(m1,m2, 'minus', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'minus', varargin{:}); % in-place operation
  s = m1;
end
