function s = acos(self, varargin)
% ACOS   Inverse cosine, result in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(acos(m))
% See also: acos

if nargout
  s = unary(self, 'acos', 'InPLace', false, varargin{:});
else
  unary(self, 'acos', varargin{:}); % in-place operation
  s = self;
end
