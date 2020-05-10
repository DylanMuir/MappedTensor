function s = acosh(self, varargin)
% ACOSH  Inverse hyperbolic cosine.
%
% Example: m=MappedTensor(rand(100)); ~isempty(acosh(m))
% See also: acosh

if nargout
  s = unary(self, 'acosh', 'InPLace', false, varargin{:});
else
  unary(self, 'acosh', varargin{:}); % in-place operation
  s = self;
end
