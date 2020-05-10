function s = sinh(self, varargin)
% SINH   Hyperbolic sine.
%
% Example: m=MappedTensor(rand(100)); ~isempty(sinh(m))
% See also: sinh

if nargout
  s = unary(self, 'sinh', 'InPLace', false, varargin{:});
else
  unary(self, 'sinh', varargin{:}); % in-place operation
  s = self;
end
