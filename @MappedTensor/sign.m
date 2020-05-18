function s = sign(self, varargin)
% SIGN   Signum function. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(sign(m))
% See also: sign

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
