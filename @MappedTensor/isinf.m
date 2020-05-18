function s = isinf(self, varargin)
% ISINF  True for infinite elements. (unary op) 
%
% Example: m=MappedTensor(rand(100)); ~isempty(isinf(m))
% See also: isinf

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
