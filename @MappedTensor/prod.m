function s = prod(self, varargin)
% PROD Product of elements. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(prod(m))
% See also: prod

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
