function s = plus(m1, m2, varargin)
% +   Plus.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(plus(m,n))
% See also: plus

if nargout
  s = binary(m1,m2, 'plus', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'plus', varargin{:}); % in-place operation
  s = m1;
end
