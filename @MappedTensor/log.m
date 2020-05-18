function s = log(self, varargin)
% LOG    Natural logarithm. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(log(m))
% See also: log

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
