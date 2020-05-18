function s = tanh(self, varargin)
% TANH   Hyperbolic tangent. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(tanh(m))
% See also: tanh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
