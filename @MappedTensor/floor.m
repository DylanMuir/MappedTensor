function s = floor(self, varargin)
% FLOOR  Round towards minus infinity. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(floor(m))
% See also: floor

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
