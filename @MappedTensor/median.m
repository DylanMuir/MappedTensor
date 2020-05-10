function s = median(self, varargin)
% MEDIAN Median value.
%
% Example: m=MappedTensor(rand(100)); ~isempty(median(m))
% See also: median

if nargout
  s = unary(self, 'median', 'InPLace', false, varargin{:});
else
  unary(self, 'median', varargin{:}); % in-place operation
  s = self;
end
