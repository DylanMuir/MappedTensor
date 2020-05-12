function s = del2(self, varargin)
% DEL2 Discrete Laplacian. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(del2(m))
% See also: del2

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
