function s = var(self, varargin)
% VAR Variance. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(var(m))
% See also: var

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
