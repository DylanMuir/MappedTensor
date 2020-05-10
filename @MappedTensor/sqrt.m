function s = sqrt(self, varargin)
% SQRT   Square root.
%
% Example: m=MappedTensor(rand(100)); ~isempty(sqrt(m))
% See also: sqrt

if nargout
  s = unary(self, 'sqrt', 'InPLace', false, varargin{:});
else
  unary(self, 'sqrt', varargin{:}); % in-place operation
  s = self;
end
