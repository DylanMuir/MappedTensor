function s = asinh(self, varargin)
% ASINH  Inverse hyperbolic sine.
%
% Example: m=MappedTensor(rand(100)); ~isempty(asinh(m))
% See also: asinh

if nargout
  s = unary(self, 'asinh', 'InPLace', false, varargin{:});
else
  unary(self, 'asinh', varargin{:}); % in-place operation
  s = self;
end
