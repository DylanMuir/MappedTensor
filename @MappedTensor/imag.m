function s = imag(self, varargin)
% IMAG   Complex imaginary part.
%
% Example: m=MappedTensor(rand(100)); ~isempty(imag(m))
% See also: imag

if nargout
  s = unary(self, 'imag', 'InPLace', false, varargin{:});
else
  unary(self, 'imag', varargin{:}); % in-place operation
  s = self;
end
