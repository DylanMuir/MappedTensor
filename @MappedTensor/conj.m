function s = conj(self, varargin)
% CONJ   Complex conjugate. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(conj(m))
% See also: conj

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
