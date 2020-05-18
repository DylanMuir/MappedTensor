function s = median(self, varargin)
% MEDIAN Median value. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(median(m))
% See also: median

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
