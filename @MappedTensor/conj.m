function s = conj(self, varargin)
% CONJ   Complex conjugate.
%
% Example: m=MappedTensor(rand(100)); ~isempty(conj(m))
% See also: conj

if nargout
  s = unary(self, 'conj', 'InPLace', false, varargin{:});
else
  unary(self, 'conj', varargin{:}); % in-place operation
  s = self;
end
