function s = prod(self, varargin)
% PROD Product of elements.
%
% Example: m=MappedTensor(rand(100)); ~isempty(prod(m))
% See also: prod

if nargout
  s = unary(self, 'prod', 'InPLace', false, varargin{:});
else
  unary(self, 'prod', varargin{:}); % in-place operation
  s = self;
end
