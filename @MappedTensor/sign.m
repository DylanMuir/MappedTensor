function s = sign(self, varargin)
% SIGN   Signum function.
%
% Example: m=MappedTensor(rand(100)); ~isempty(sign(m))
% See also: sign

if nargout
  s = unary(self, 'sign', 'InPLace', false, varargin{:});
else
  unary(self, 'sign', varargin{:}); % in-place operation
  s = self;
end
