function s = var(self, varargin)
% VAR Variance.
%
% Example: m=MappedTensor(rand(100)); ~isempty(var(m))
% See also: var

if nargout
  s = unary(self, 'var', 'InPLace', false, varargin{:});
else
  unary(self, 'var', varargin{:}); % in-place operation
  s = self;
end
