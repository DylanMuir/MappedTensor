function s = real(self, varargin)
% REAL   Complex real part.
%
% Example: m=MappedTensor(rand(100)); ~isempty(real(m))
% See also: real

if nargout
  s = unary(self, 'real', 'InPLace', false, varargin{:});
else
  unary(self, 'real', varargin{:}); % in-place operation
  s = self;
end
