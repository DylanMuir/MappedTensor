function s = del2(self, varargin)
% DEL2 Discrete Laplacian.
%
% Example: m=MappedTensor(rand(100)); ~isempty(del2(m))
% See also: del2

if nargout
  s = unary(self, 'del2', 'InPLace', false, varargin{:});
else
  unary(self, 'del2', varargin{:}); % in-place operation
  s = self;
end
