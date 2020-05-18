function s = atanh(self, varargin)
% ATANH  Inverse hyperbolic tangent. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(atanh(m))
% See also: atanh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
