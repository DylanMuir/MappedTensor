function s = power(m1, m2, varargin)
% .^  Array power.
%
% Example: m=MappedTensor(rand(100)); n=MappedTensor(rand(100)); ~isempty(power(m,n))
% See also: power

if nargout
  s = binary(m1,m2, 'power', 'InPLace', false, varargin{:});
else
  binary(m1,m2, 'power', varargin{:}); % in-place operation
  s = m1;
end
