function s = isnan(self, varargin)
% ISNAN  True for Not-a-Number. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(isnan(m))
% See also: isnan

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
