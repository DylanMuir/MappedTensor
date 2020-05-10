function s = cosh(self, varargin)
% COSH   Hyperbolic cosine.
%
% Example: m=MappedTensor(rand(100)); ~isempty(cosh(m))
% See also: cosh

if nargout
  s = unary(self, 'cosh', 'InPLace', false, varargin{:});
else
  unary(self, 'cosh', varargin{:}); % in-place operation
  s = self;
end
