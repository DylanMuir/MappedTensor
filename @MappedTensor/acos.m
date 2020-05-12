function s = acos(self, varargin)
% ACOS   Inverse cosine, result in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(acos(m))
% See also: acos

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
