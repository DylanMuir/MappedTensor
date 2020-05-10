function s = isnan(self, varargin)
% ISNAN  True for Not-a-Number.
%
% Example: m=MappedTensor(rand(100)); ~isempty(isnan(m))
% See also: isnan

if nargout
  s = unary(self, 'isnan', 'InPLace', false, varargin{:});
else
  unary(self, 'isnan', varargin{:}); % in-place operation
  s = self;
end
