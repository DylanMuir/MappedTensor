function s = sinh(self, varargin)
% SINH   Hyperbolic sine. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(sinh(m))
% See also: sinh

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
