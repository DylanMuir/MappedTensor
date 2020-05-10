function s = tanh(self, varargin)
% TANH   Hyperbolic tangent.
%
% Example: m=MappedTensor(rand(100)); ~isempty(tanh(m))
% See also: tanh

if nargout
  s = unary(self, 'tanh', 'InPLace', false, varargin{:});
else
  unary(self, 'tanh', varargin{:}); % in-place operation
  s = self;
end
