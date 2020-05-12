function s = exp(self, varargin)
% EXP    Exponential. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(exp(m))
% See also: exp

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
