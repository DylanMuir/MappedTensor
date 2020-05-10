function s = mean(self, varargin)
% MEAN   Average or mean value.
%
% Example: m=MappedTensor(rand(100)); ~isempty(mean(m))
% See also: mean

if nargout
  s = unary(self, 'mean', 'InPLace', false, varargin{:});
else
  unary(self, 'mean', varargin{:}); % in-place operation
  s = self;
end
