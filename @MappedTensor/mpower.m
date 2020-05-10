function s = mpower(m1, m2, varargin)
% ^   Matrix power.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(mpower(m,n))
% See also: mpower

if nargout
  s = binary(m1,m2, 'mpower', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'mpower', varargin{:}); % in-place operation
  s = m1;
end
