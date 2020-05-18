function s = round(self, varargin)
% ROUND  Round towards nearest integer. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(round(m))
% See also: round

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
