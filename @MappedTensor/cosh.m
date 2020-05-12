function s = cosh(self, varargin)
% COSH   Hyperbolic cosine. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(cosh(m))
% See also: cosh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
