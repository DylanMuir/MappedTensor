function s = abs(self, varargin)
% ABS    Absolute value. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(abs(m))
% See also: abs

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
