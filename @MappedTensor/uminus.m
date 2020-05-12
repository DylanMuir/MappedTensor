function s = uminus(self, varargin)
% -  Unary minus. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(uminus(m))
% See also: uminus

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
