function s = acosh(self, varargin)
% ACOSH  Inverse hyperbolic cosine. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(acosh(m))
% See also: acosh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
