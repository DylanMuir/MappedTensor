function s = sqrt(self, varargin)
% SQRT   Square root. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(sqrt(m))
% See also: sqrt

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
