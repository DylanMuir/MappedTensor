function s = atanh(self, varargin)
% ATANH  Inverse hyperbolic tangent.
%
% Example: m=MappedTensor(rand(100)); ~isempty(atanh(m))
% See also: atanh

if nargout
  s = unary(self, 'atanh', 'InPLace', false, varargin{:});
else
  unary(self, 'atanh', varargin{:}); % in-place operation
  s = self;
end
