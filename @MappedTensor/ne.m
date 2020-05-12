function s = ne(m1, m2, varargin)
% ~=  Not equal. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=2*m; ~isempty(ne(m,n))
% See also: ne

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
