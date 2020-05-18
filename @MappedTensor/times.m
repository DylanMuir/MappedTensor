function s = times(m1, m2, varargin)
% .*  Array multiply. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(times(m,n))
% See also: times

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
