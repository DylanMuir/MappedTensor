function s = mtimes(m1, m2, varargin)
% *   Matrix multiply.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(mtimes(m,n))
% See also: mtimes

if nargout
  s = binary(m1,m2, 'mtimes', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'mtimes', varargin{:}); % in-place operation
  s = m1;
end
