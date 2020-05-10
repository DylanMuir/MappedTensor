function s = sin(self, varargin)
% SIN    Sine of argument in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(sin(m))
% See also: sin

if nargout
  s = unary(self, 'sin', 'InPLace', false, varargin{:});
else
  unary(self, 'sin', varargin{:}); % in-place operation
  s = self;
end
