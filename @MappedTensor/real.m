function s = real(self, varargin)
% REAL   Real part. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(real(m))
% See also: real

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
