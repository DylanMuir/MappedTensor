function s = any(self, varargin)
% ANY    True if any element of a tensor is a nonzero number or is
%
% Example: m=MappedTensor(rand(100)); ~isempty(any(m))
% See also: any

if nargout
  s = unary(self, 'any', 'InPLace', false, varargin{:});
else
  unary(self, 'any', varargin{:}); % in-place operation
  s = self;
end
