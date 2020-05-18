function s = or(m1, m2, varargin)
% |   Logical OR. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=copyobj(m); ~isempty(or(m,n))
% See also: or

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
