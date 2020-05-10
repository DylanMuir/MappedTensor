function s = times(m1, m2, varargin)
% .*  Array multiply.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(times(m,n))
% See also: times

if nargout
  s = binary(m1,m2, 'times', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'times', varargin{:}); % in-place operation
  s = m1;
end
