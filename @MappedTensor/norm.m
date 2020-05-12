function s = norm(self, varargin)
% NORM   Matrix or tensor norm. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(norm(m))
% See also: norm

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
