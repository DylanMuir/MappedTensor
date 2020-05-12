function s = cumprod(self, varargin)
% CUMPROD Cumulative product of elements. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(cumprod(m))
% See also: cumprod

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
