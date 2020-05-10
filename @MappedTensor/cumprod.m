function s = cumprod(self, varargin)
% CUMPROD Cumulative product of elements.
%
% Example: m=MappedTensor(rand(100)); ~isempty(cumprod(m))
% See also: cumprod

if nargout
  s = unary(self, 'cumprod', 'InPLace', false, varargin{:});
else
  unary(self, 'cumprod', varargin{:}); % in-place operation
  s = self;
end
