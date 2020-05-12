function s = tan(self, varargin)
% TAN    Tangent of argument in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(tan(m))
% See also: tan

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
