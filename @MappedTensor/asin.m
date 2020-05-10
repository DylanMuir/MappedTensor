function s = asin(self, varargin)
% ASIN   Inverse sine, result in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(asin(m))
% See also: asin

if nargout
  s = unary(self, 'asin', 'InPLace', false, varargin{:});
else
  unary(self, 'asin', varargin{:}); % in-place operation
  s = self;
end
