function s = lt(m1, m2, varargin)
% <  Less than.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(lt(m,n))
% See also: lt

if nargout
  s = binary(m1,m2, 'lt', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'lt', varargin{:}); % in-place operation
  s = m1;
end
