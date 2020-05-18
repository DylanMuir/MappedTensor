function s = mean(self, varargin)
% MEAN   Average or mean value. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(mean(m))
% See also: mean

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
