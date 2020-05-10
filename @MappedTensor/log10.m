function s = log10(self, varargin)
% LOG10  Common (base 10) logarithm.
%
% Example: m=MappedTensor(rand(100)); ~isempty(log10(m))
% See also: log10

if nargout
  s = unary(self, 'log10', 'InPLace', false, varargin{:});
else
  unary(self, 'log10', varargin{:}); % in-place operation
  s = self;
end
