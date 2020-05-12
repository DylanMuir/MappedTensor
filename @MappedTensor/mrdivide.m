function s = mrdivide(m1, m2, varargin)
% /   Slash or right matrix divide. (binary op)
%
% Example: m=MappedTensor(rand(10,10,10)); n=copyobj(m); ~isempty(mrdivide(m,n))
% See also: mrdivide

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
