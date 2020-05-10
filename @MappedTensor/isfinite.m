function s = isfinite(self, varargin)
% ISFINITE True for finite elements.
%
% Example: m=MappedTensor(rand(100)); ~isempty(isfinite(m))
% See also: isfinite

if nargout
  s = unary(self, 'isfinite', 'InPLace', false, varargin{:});
else
  unary(self, 'isfinite', varargin{:}); % in-place operation
  s = self;
end
