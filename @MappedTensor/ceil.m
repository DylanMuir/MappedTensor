function s = ceil(self, varargin)
% CEIL   Round towards plus infinity. (unary op)
%
% Example: m=MappedTensor(rand(100)); ~isempty(ceil(m))
% See also: ceil

if nargout
  s = unary(self, mfilename, varargin{:}, 'InPlace', false);
else
  unary(self, mfilename, varargin{:}); % in-place operation
  s = self;
end
