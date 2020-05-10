function s = cos(self, varargin)
% COS    Cosine of argument in radians.
%
% Example: m=MappedTensor(rand(100)); ~isempty(cos(m))
% See also: cos

if nargout
  s = unary(self, 'cos', 'InPLace', false, varargin{:});
else
  unary(self, 'cos', varargin{:}); % in-place operation
  s = self;
end
