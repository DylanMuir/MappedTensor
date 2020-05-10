function s = tan(self, varargin)
% TAN    Tangent of argument in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(tan(m))
% See also: tan

if nargout
  s = unary(self, 'tan', 'InPLace', false, varargin{:});
else
  unary(self, 'tan', varargin{:}); % in-place operation
  s = self;
end
