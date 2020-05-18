function s = isfinite(self, varargin)
% ISFINITE True for finite elements. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(isfinite(m))
% See also: isfinite

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
