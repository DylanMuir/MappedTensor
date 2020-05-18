function s = asinh(self, varargin)
% ASINH  Inverse hyperbolic sine. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(asinh(m))
% See also: asinh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
