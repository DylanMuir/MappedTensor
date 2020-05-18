function s = cumsum(self, varargin)
% CUMSUM Cumulative sum of elements. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(cumsum(m))
% See also: cumsum

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
