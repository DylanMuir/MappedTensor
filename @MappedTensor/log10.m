function s = log10(self, varargin)
% LOG10  Common (base 10) logarithm. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(log10(m))
% See also: log10

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
