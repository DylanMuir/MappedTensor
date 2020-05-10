function s = isinf(self, varargin)
% ISINF  True for infinite elements.
%
% Example: m=MappedTensor(rand(100)); ~isempty(isinf(m))
% See also: isinf

if nargout
  s = unary(self, 'isinf', 'InPLace', false, varargin{:});
else
  unary(self, 'isinf', varargin{:}); % in-place operation
  s = self;
end
