function s = sin(self, varargin)
% SIN    Sine of argument in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(sin(m))
% See also: sin

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
