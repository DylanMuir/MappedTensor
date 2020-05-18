function s = atan(self, varargin)
% ATAN   Inverse tangent, result in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(atan(m))
% See also: atan

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
