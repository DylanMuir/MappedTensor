function s = mtimes(m1, m2, varargin)
% *   Matrix multiply. (binary op)
%
% Example: m=MappedTensor(rand(10,10,10)); n=copyobj(m); ~isempty(mtimes(m,n))
% See also: mtimes

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
