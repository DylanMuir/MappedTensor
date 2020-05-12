function s = asin(self, varargin)
% ASIN   Inverse sine, result in radians. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(asin(m))
% See also: asin

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
