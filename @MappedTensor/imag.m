function s = imag(self, varargin)
% IMAG   Complex imaginary part. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(imag(m))
% See also: imag

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
