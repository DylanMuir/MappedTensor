function s = not(self, varargin)
% ~   Logical NOT. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(not(m))
% See also: not

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
