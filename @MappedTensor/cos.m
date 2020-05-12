function s = cos(self, varargin)
% COS    Cosine of argument in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(cos(m))
% See also: cos

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
