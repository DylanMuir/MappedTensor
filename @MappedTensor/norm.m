function s = norm(self, varargin)
% NORM   Matrix or tensor norm.
%
% Example: m=MappedTensor(rand(100)); ~isempty(norm(m))
% See also: norm

if nargout
  s = unary(self, 'norm', 'InPLace', false, varargin{:});
else
  unary(self, 'norm', varargin{:}); % in-place operation
  s = self;
end
