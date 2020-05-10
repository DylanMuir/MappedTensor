function s = gt(m1, m2, varargin)
% >  Greater than.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(gt(m,n))
% See also: gt

if nargout
  s = binary(m1,m2, 'gt', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'gt', varargin{:}); % in-place operation
  s = m1;
end
