function s = plus(m1, m2, varargin)
% +   Plus. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=copyobj(m); ~isempty(plus(m,n))
% See also: plus

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
