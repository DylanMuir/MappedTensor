function s = exp(self, varargin)
% EXP    Exponential.
%
% Example: m=MappedTensor(rand(100)); ~isempty(exp(m))
% See also: exp

if nargout
  s = unary(self, 'exp', 'InPLace', false, varargin{:});
else
  unary(self, 'exp', varargin{:}); % in-place operation
  s = self;
end
