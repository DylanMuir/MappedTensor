function s = mpower(m1, m2, varargin)
% ^   Matrix power. (binary op)
%
% Example: m=MappedTensor(rand(10,10,10)); ~isempty(mpower(m,2))
% See also: mpower

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
