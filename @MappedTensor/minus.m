function s = minus(m1, m2, varargin)
% -   Minus. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=copyobj(m); ~isempty(minus(m,n))
% See also: minus

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
