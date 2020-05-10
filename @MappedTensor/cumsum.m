function s = cumsum(self, varargin)
% CUMSUM Cumulative sum of elements.
%
% Example: m=MappedTensor(rand(100)); ~isempty(cumsum(m))
% See also: cumsum

if nargout
  s = unary(self, 'cumsum', 'InPLace', false, varargin{:});
else
  unary(self, 'cumsum', varargin{:}); % in-place operation
  s = self;
end
