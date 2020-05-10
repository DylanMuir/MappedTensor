function s = log(self, varargin)
% LOG    Natural logarithm.
%
% Example: m=MappedTensor(rand(100)); ~isempty(log(m))
% See also: log

if nargout
  s = unary(self, 'log', 'InPLace', false, varargin{:});
else
  unary(self, 'log', varargin{:}); % in-place operation
  s = self;
end
