function s = abs(self, varargin)
% ABS    Absolute value.
%
% Example: m=MappedTensor(rand(100)); ~isempty(abs(m))
% See also: abs

if nargout
  s = unary(self, 'abs', 'InPLace', false, varargin{:});
else
  unary(self, 'abs', varargin{:}); % in-place operation
  s = self;
end
