function s = ge(m1, m2, varargin)
% >=  Greater than or equal. (binary op)
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(ge(m,n))
% See also: ge

if nargout
  s = binary(m1,m2, mfilename, varargin{:}, 'InPlace', false);
else
  binary(m1,m2, mfilename, varargin{:}); % in-place operation
  s = m1;
end
